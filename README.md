# Docker-Fluentd: the Container to Log Other Containers' Logs

## What

By running this container with the following command, one can aggregate the stdout logs and system metrics of Docker containers running on the same host, and include extra data such as host name, image name, and container name:

```
docker run -e HOST="$(uname -n)" --name docker_fluentd -d -v /sys/fs/cgroup:/mnt/cgroup -v /var/lib/docker/containers:/var/lib/docker/containers -v /var/run/docker.sock:/var/run/docker.sock nathanpower/docker-fluentd
```

For the moment, the container logs are stored in /var/lib/docker/containers/yyyyMMdd.log on the host. Going forward the plan is to output the data to another fluentd instance over TCP. The data is buffered, so you may also see buffer files like /var/lib/docker/containers/20141114.b507c71e6fe540eab.log where "b507c71e6fe540eab" is a hash identifier. You can mount that container volume back to host. Also, by modifying `fluent.conf` and rebuilding the Docker image, you can stream up your logs to LogEntries, Elasticsearch, Amazon S3, MongoDB, Treasure Data, or another FluentD instance.

The output log looks exactly like Docker's JSON formatted logs, with extra information about the container and host:

```
{
  "log": "hello world\n",
  "stream": "stdout",
  "host": "osboxes",
  "short_id": "b049b768ab62",
  "long_id": "b8aa72148d6bd0d01ae21a19e24d74c4ba7efa1826e5eaad7e66a5bee9c36e00",
  "image": "ubuntu:14_04",
  "name": "daemon_dave",
  "time": "2015-04-12T12:39:08+00:00"
}

```

System log:

```
{
  "key": "memory_stat_hierarchical_memsw_limit",
  "value": 1.844674407371e+19,
  "type": "gauge",
  "name": "\/daemon_dave",
  "host": "osboxes",
  "short_id": "b049b768ab62",
  "long_id": "b8aa72148d6bd0d01ae21a19e24d74c4ba7efa1826e5eaad7e66a5bee9c36e00",
  "time": "2015-04-12T12:39:39+00:00"
}
```

## How

`docker-fluentd` uses [Fluentd](https://www.fluentd.org) inside to tail log files that are mounted on `/var/lib/docker/containers/<CONTAINER_ID>/<CONTAINER_ID>-json.log`. It uses the [tail input plugin](https://docs.fluentd.org/articles/in_tail) to tail JSON-formatted log files that each Docker container emits. System metrics are gathered using [docker metrics](https://github.com/kiyoto/fluent-plugin-docker-metrics). 

The tags are modified to include details such as container name, image name, and container id using [tag resolver](https://github.com/ainoya/fluent-plugin-docker-tag-resolver). This data is added to the log event using the [record reformer](https://github.com/sonots/fluent-plugin-record-reformer), before writing out to local files using the [file output plugin](https://docs.fluentd.org/articles/out_file).


