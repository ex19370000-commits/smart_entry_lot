#!/bin/bash
set -e

rm -f /smart_entry_lot/tmp/pids/server.pid
exec "$@"