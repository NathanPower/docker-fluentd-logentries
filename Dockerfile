FROM kiyoto/fluentd:0.10.56-2.1.1
MAINTAINER nathanpower78@gmail.com

RUN mkdir /etc/fluent
RUN mkdir /etc/fluent/plugin
ADD fluent.conf /etc/fluent/
ADD logentries-tokens.conf /etc/fluent/
ADD out_logentries.rb /etc/fluent/plugin/
RUN ["/usr/local/bin/gem", "install", "fluent-plugin-secure-forward"]
EXPOSE 24284
ENTRYPOINT ["/usr/local/bin/fluentd", "-c", "/etc/fluent/fluent.conf", "--use-v1-config"]
