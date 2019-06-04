#!/bin/bash

mkdir -p src dst work

#### Find differences ####
echo "Files that will be deleted:"
rsync -a --checksum --verbose --delete --dry-run src/ dst/ | grep "^deleting " | sed -e "s|^deleting ||g" | grep -ve '/$' | tee /tmp/delete

echo

echo "Files that will be overwritten:"
rsync -a --checksum --verbose --dry-run src/ dst/ | grep -ve '^$' -ve '^sending incremental' -ve '^./' -ve '^sent .* bytes' -ve '^total size is ' -ve '/$' | tee /tmp/overwrite

#### Save differences ####
id=`uuidgen`

for f in `cat /tmp/delete`
do
  dir=`dirname $f`
  mkdir -p "work/$id/delete/$dir"
  cp dst/$f "work/$id/delete/$f"
done

for f in `cat /tmp/overwrite`
do
  dir=`dirname $f`
  mkdir -p "work/$id/overwrite/$dir"
  cp dst/$f "work/$id/overwrite/$f"
done

#### Sync ####
echo
echo "Press enter to sync"
read
rsync -a --verbose --human-readable --delete src/ dst/
