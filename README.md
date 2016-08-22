Predictive
==========

This is a library for predictive scans.  Its aim is to improve user
experience in cases when user interactions have to be acknowledged by a
remote host.  It closes the gap between requesting the interaction and
the remote end acknowledging it by predicting what the remote end will
decide based on local information.  If the prediction is wrong, it
automatically backtracks to the last state known to be consistent.

Simple example:  Your application displays a client-side text box, but
each edit made to it has to be acknowledged by a server.  However, most
of the time the server will acknowledge, so your application can use
this library to proceed under this assumption and only backtrack, if the
server disagrees.
