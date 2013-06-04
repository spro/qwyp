#!/bin/sh

coffee server.coffee testpass 2222 3333 8022 &
coffee server.coffee testpass 3333 2222 8033 &

open http://localhost:8022/?name=fred
open http://localhost:8033/?name=joe
