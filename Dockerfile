FROM python:3.7.7-slim-buster

RUN apt-get update && apt-get install -yqq cron

## Dagster

ENV DAGSTER_VERSION=0.7.13
ENV DAGSTER_HOME=/opt/dagster/home
ENV DAGSTER_APP=/opt/dagster/app
ENV DAGSTER_DAGS=/opt/dagster/dags

RUN mkdir -p ${DAGSTER_HOME} ${DAGSTER_APP}
RUN pip install \
      dagster==${DAGSTER_VERSION} \
      dagit==${DAGSTER_VERSION} \
      dagster-spark==${DAGSTER_VERSION} \
      dagster-pyspark==${DAGSTER_VERSION} \
      dagster-celery==${DAGSTER_VERSION} \
      dagster-postgres==${DAGSTER_VERSION} \
      dagster-aws==${DAGSTER_VERSION} \
      dagster-pandas==${DAGSTER_VERSION} \
      dagster_cron==${DAGSTER_VERSION} \
      s3fs==0.4.2

## Local Spark
ENV SPARK_VERSION=2.4.5
ENV HADOOP_VERSION=2.7
ENV SPARK_HOME=/spark

RUN apt-get update \
    && apt-get install -y curl gnupg software-properties-common \
    && curl https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
    && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
    && apt-get update \
    && mkdir /usr/share/man/man1 \
    && apt-get install -y adoptopenjdk-8-hotspot

RUN curl -O https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME} \
    && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

## SOPS
ENV SOPS_VERSION=3.5.0
RUN curl -L -O https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb \
    && dpkg -i sops_${SOPS_VERSION}_amd64.deb

## Entrypoint
WORKDIR ${DAGSTER_DAGS}
VOLUME ${DAGSTER_DAGS}

COPY entrypoint.sh ${DAGSTER_APP}/entrypoint.sh
RUN chmod +x ${DAGSTER_APP}/entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/opt/dagster/app/entrypoint.sh"]
