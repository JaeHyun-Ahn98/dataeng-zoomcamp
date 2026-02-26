# SPARK / PYTHON
$env:SPARK_HOME = "C:\tools\spark-3.3.2-bin-hadoop3"
$env:PYTHONPATH = "C:\tools\spark-3.3.2-bin-hadoop3\python;C:\tools\spark-3.3.2-bin-hadoop3\python\lib\py4j-0.10.9.5-src.zip;" + $env:PYTHONPATH


$env:PYTHONPATH = "$env:SPARK_HOME\python\;" + $env:PYTHONPATH
$env:PYTHONPATH = "$env:SPARK_HOME\python\lib\py4j-0.10.9-src.zip\;" + $env:PYTHONPATH