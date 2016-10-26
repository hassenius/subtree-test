Request Based Log Queue
=======================

[![Build Status](https://travis-ci.org/egymgmbh/log-queue.svg?branch=master)](https://travis-ci.org/egymgmbh/log-queue)

This little library provides an [slf4j](http://www.slf4j.org/)
compatible logging system which allows to log on a request level by
queueing all log outputs while a request is in progress and then
flushing them all at once as soon as the request is done.

This approach is heavily inspired by the
[Optimal Logging](http://googletesting.blogspot.de/2013/06/optimal-logging.html)
post on the Google Testing Blog.

Use Case
--------

Imagine you have a system, eg. a web server, which processes hundreds
of requests per second, each of them producing several log messages. A
typical problem you are facing is that the requests overlap and that
therefore the log messages are all scrambled together, making them hard
to read.

Logs typically look something like this:

```
10:28:50.910 [15793] INFO Processing GET /foo/bar
10:28:51.007 [15793] INFO Logged in user is 3219856548295
10:28:51.008 [29845] INFO Processing POST /foo/bar
10:28:51.758 [29845] INFO Logged in user is 29386549367621
10:28:52.042 [15793] WARN User has no settings
10:28:52.123 [29845] INFO Created foo with id 4967
10:28:52.473 [15793] INFO Found foo with id 5321
10:28:52.480 [15793] INFO Returning status 200
10:28:53.011 [29845] INFO Calling getBar(4967)
10:28:53.200 [29845] INFO Retrieved bar in 165ms
10:28:53.856 [29845] INFO Returning status 204
```

Note that the thread ID in square brackets is your only chance to
associate log entries to requests.

With Request Based Log Queue you can achieve something like this:

```
10:28:50.891 Request GET /foo/bar
    10:28:50.910 INFO Processing GET /foo/bar
    10:28:51.007 INFO Logged in user is 3219856548295
    10:28:52.042 WARN User has no settings
    10:28:52.473 INFO Found foo with id 5321
    10:28:52.480 INFO Returning status 200

10:28:50.998 Request POST /foo/bar
    10:28:51.008 INFO Processing POST /foo/bar
    10:28:51.758 INFO Logged in user is 29386549367621
    10:28:52.123 INFO Created foo with id 4967
    10:28:53.011 INFO Calling getBar(4967)
    10:28:53.200 INFO Retrieved bar in 165ms
    10:28:53.856 INFO Returning status 204
```

Architecture
------------

The log queue utilizes pipelines to process log records. The
EgymLogQueue collects all the log records for a request and sends them
into all of the configured pipelines once a request is finished.

A log pipeline consists of the following components:
* EgymLogDecorator adds meta information, like the called URL, the
  remote IP address and the HTTP status code, to the request log
  record.
* EgymLogFormatter is in charge of converting the request log record
  into a custom format, eg. plain text or JSON.
* EgymLogWriter is the last step in the pipeline and is in charge of
  sending the log records to the console, to a file, or to an
  external system.

The library allows you to use custom implementations for all of these
components and it is straightforward to configure multiple pipelines.

It is recommended to take a look at the default implementations to get
an idea of how things work:
* de.egym.logging.decorator.EgymLogNoOpDecorator
* de.egym.logging.formatter.EgymLogPlainTextFormatter
* de.egym.logging.writer.EgymLogStdOutWriter

Requirements
------------

The library is built around slf4j. If you're already using slf4j you do
not have to change any of your existing logging code.

Configuration
-------------

The pipeline configuration uses an [EDSL](https://en.wikipedia.org/wiki/EDSL)
(embedded domain specific language) built using
[Guice](https://code.google.com/p/google-guice/). To configure a
pipeline you have to extend the EgymLogPipelineModule class and
implement the configure() method.

The EDSL looks like this:

```java
decorateWith(YourDecorator.class)
    .formatWith(YourFormatter.class)
    .writeTo(YourWriter.class);
```

If you don't need a decorator you can replace the first line with:

```java
skipDecoration()
```

If you just want to log plain-text to stdout you can use:

```java
skipDecoration()
    .formatWith(EgymLogPlainTextFormatter.class)
    .writeTo(EgymLogStdOutWriter.class)
```

Request Control
---------------

To tell the library when a request starts and ends you need to call the
following methods:

```java
logQueue.startRequest();
// Your request logic
logQueue.endRequest();
```

If your application is HTTP based, the easiest way to achieve this is
to implement javax.servlet.Filter and configure it to intercept all
your requests.

```java
@Override
public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse,
    FilterChain filterChain) throws IOException, ServletException {

    logQueue.startRequest();
    filterChain.doFilter(servletRequest, servletResponse);
    logQueue.endRequest();
}
```
