/bin/bash

/usr/bin/php /var/www/wiki/maintenance/update.php --quick && \
    /usr/bin/php /var/www/wiki/maintenance/importDump.php < /tmp/struktur.xml && \
    /usr/bin/php /var/www/wiki/maintenance/runJobs.php
