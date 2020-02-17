import subprocess
from flask import Flask


app = Flask(__name__)


@app.route('/runjobs')
def runjobs():
    subprocess.run(
        [
            "/usr/bin/php",
            "/var/www/wiki/maintenance/runJobs.php",
            "--maxtime",
            "1800"  # 30 minute running time limit
        ])
    return '', 200


if __name__ == '__main__':
    app.run()
