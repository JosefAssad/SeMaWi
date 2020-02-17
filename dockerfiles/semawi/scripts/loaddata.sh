/bin/bash

/usr/bin/php /var/www/wiki/maintenance/update.php --quick && \
    /usr/bin/php /var/www/wiki/maintenance/importDump.php --no-updates < /tmp/struktur.xml && \
    /usr/bin/php /var/www/wiki/maintenance/rebuildall.php && \
    /usr/bin/php /var/www/wiki/maintenance/runJobs.php
