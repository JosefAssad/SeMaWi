from flask import Flask
import mwclient
import os
import json
import re
from lxml import html
import urllib


app = Flask(__name__)

username = os.environ['SEMAWI_GC2_BOT_USER']
password = os.environ['SEMAWI_GC2_BOT_PASS']
gc2_url = os.environ['SEMAWI_GC2_URL']

geodata_tables = []

template = """{{Geodata
|Titel=%s
|Beskrivelse=%s
|Skema=%s
|Tabelnavn=%s
|Laggruppe=%s
|SRID=%s
|Geometritype=%s
|KLE-numre=%s
|Dataansvar=%s
|URL=%s
|GUID=%s
}}
"""


def delete_cat(site, category):
    """ Deletes all pages in category """
    for page in site.Categories[category]:
        page.delete()


def generate(tables):

    count = 0
    for table in tables:

        t = {}
        count += 1

        if table['uuid'] is not None:
            guid = table['uuid']
        else:
            guid = ''  # should NEVER happen, maybe implement somme syslogging

        if table['extra'] is not None:
            if table['extra'].strip() is not None:
                extra = 'Emne_' + table['extra'].strip()
            else:
                extra = ''
        else:
            extra = ''

        if table['layergroup'] is None:
            layergroup = ''
        elif re.match('.*Ungrouped.*', table['layergroup']):
            layergroup = 'Ungrouped'
        elif table['layergroup'] is not None:
            layergroup = table['layergroup']

        if table['f_table_abstract'] == "":
            f_table_abstract = ''
        elif table['f_table_abstract'] is not None:
            f_table_abstract = html.fromstring(
                table['f_table_abstract']).text_content()
        else:
            f_table_abstract = ''

        if table['type'] is not None:
            ttype = table['type']
        else:
            ttype = ''
        if table['f_table_schema'] is not None:
            f_table_schema = table['f_table_schema']
            # we will include only those tables for which the schema:
            # 1. starts with _XX_ both X'es being digits, and
            # 2. NOT _00_
            included = False  # we are whitelisting tables
            if re.search('^_[0-9]{2}_.*', f_table_schema):
                if f_table_schema[:4] != '_00_':
                    included = True
        else:
            f_table_schema = ''  # probably not possible? Just being safe

        if table['srid'] is not None:
            srid = table['srid']
        else:
            srid = ''
        if table['f_table_name'] is not None:
            f_table_name = table['f_table_name']
        else:
            f_table_name = ''
        if table['f_table_title'] is not None:
            f_table_title = table['f_table_title']
        else:
            f_table_title = ''
        gc2url = (('http://ballerup.mapcentia.com/apps/viewer/ballerup/'
                  '%s/#stamenToner/12/12.3342/55.7363/%s.%s') %
                  (f_table_schema, f_table_schema, f_table_name))

        if f_table_title != '':
            pagename = f_table_title
        else:
            if f_table_name != '':
                pagename = f_table_name
            else:
                pagename = "ERROR"  # cross fingers it's unique in GC2?
        t['title'] = 'Geodata_%s' % pagename

        t['contents'] = (template %
                         (f_table_title, f_table_abstract, f_table_schema,
                          f_table_name, layergroup, srid, ttype, extra,
                          'Bruger:Ldg', gc2url, guid))
        # Time to sort out the _00_ grundkort and others without _XX_
        if included:
            geodata_tables.append(t)
    return geodata_tables


@app.route('/')
def sync():
    # step 0: login
    site = mwclient.Site(os.environ['SEMAWI_GC2_MW_SITE'],
                         scheme=os.environ['SEMAWI_GC2_MW_SCHEME'],
                         path=os.environ['SEMAWI_GC2_MW_PATH'])
    site.login(username, password)

    # Step 1: Load gc2 json into SMW pages
    response = urllib.request.urlopen(gc2_url).read()
    gc2data = json.loads(response.read())
    gc2tables = gc2data['data']
    tables = generate(gc2tables)
    # Step 2: Delete SMW pages in the Geodata category
    delete_cat(site, 'Geodata')
    # Step 3: Create new pages for all the SMW pages generated in step 1
    for table in tables:
        page = site.Pages[table['title']]
        page.save(table['contents'], summary='GC2 geodata batch import')
    return "ok"


if __name__ == '__main__':
    app.run()
