from setuptools import setup, find_packages

required = [
    'Flask==1.1.1'
]

setup(
    name='semawi-runner',
    version='0.1',
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    install_requires=required
)
