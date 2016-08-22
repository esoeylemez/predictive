Predictive
==========

Copyright 2016 Ertugrul Söylemez

Licensed under the Apache License, Version 2.0 (the "License");
you may not use these files except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


Introduction
------------

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
