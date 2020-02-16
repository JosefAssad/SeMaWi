from setuptools import setup, find_packages

required = [
    'Flask==1.1.1',
    'lxml==4.5.0',
    'mwclient==0.10.0'
]

setup(
    name='gc2sync',
    version='0.1',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    install_requires=required
)
