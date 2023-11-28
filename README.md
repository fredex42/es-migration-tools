# Migration tools

Scripts to help move data from ancient Elasticsearch to more modern ones

## How to build

Prerequisites: Docker

While you can do this with the Ruby installed on your machine, it's actually easier and more portable to do it in a Docker
container.

With this directory checked out locally, cd to it in a Terminal and run the following to start up a session:

```
docker run --rm -it -v $PWD:/usr/src/esmigrationtools ruby:2.7 -- /bin/bash
```

This will give you a root prompt within the container.  From there, you should run:
```
# cd /usr/src/esmigrationtools
# gem install rake awesome_print optimist rspec
# rake test && rake build
```

These commands will install the necessary prerequisites, run the inline tests to make sure that the code is working 
and build a gem. This should be called `es-migration-tools-1.0.0.gem` and it will be available in /usr/src/esmigrationtools
in the container and in your local filesystem.

You can run it from the container or your machine (or copy the gem elsewhere and install it).

To install the gem, simply:
```
gem install es-migration-tools-1.0.0.gem
```

This should install the commands in /usr/local/bin.  Run any command with `--help`  to show the online help.

## download_from_old.rb
```
Options:
  -c, --cluster=<s>             Connect to Elasticsearch at this uri (default: http://localhost:9200)
  -i, --index=<s>               Download this index
  -o, --output=<s>              Output json files to this directory (default: /)
  -h, --chunksize=<i>           Get this many records per json file (default: 1000)
  -s, --sortfield=<s>           Sort by this field when retrieving (default: timestamp)
  -r, --redownload              Overwrite existing files rather than skip them
  -n, --noupdate                Don't update string fields to the newer text/keyword syntax
  -t, --truncate-field-count    If the source data has more than 1000 fields then only keep the first 1000. Using --strip-fields is
                                preferable.
  -e, --help                    Show this message
```
This script is ES v1.x compatible and will download the entire contents of an index in json files.
You need give it a directory to write its output to (a previously empty directory is recommended).  It will be populated with:
- `indexinfo-{indexname}.json` is a json dump of the index mappings and settings. This can be used to re-create the index in another version of ES
with the same mapping configuration
- `indexdata-{indexname}-{n}.json` is a json dump of a page of results. By default, the script will output 1000 records per page.
`{n}` is a number that is incremented until all of the records are output

## upload_to_new.rb
```
Options:
  -c, --cluster=<s>         Connect to Elasticsearch at this uri (default: http://localhost:9200)
  -i, --index=<s>           Create this index
  -a, --allow-overwrite     Allow the deletion of an existing index
  -n, --input=<s>           Read json files from this directory (default: /usr/src/esmigrationtools)
  -s, --strip-fields=<s>    Comma separated list of fields to remove before uploading (default: )
  -h, --help                Show this message
```

This script takes a directory full of files that was created by `download_from_old` and will upload it to a new cluster. It is 5.x compatible,
other versions may well work too.

By default it won't over-write an existing index, you have to enable this specifically on the commandline.  Later ES versions
sometimes have stricter requirements on field names or values, so you can use the `--strip-fields` option to remove any fields
that Elasticsearch complains about

## upload_to_new_mt.rb
```
Options:
  -c, --cluster=<s>         Connect to Elasticsearch at this uri (default: http://localhost:9200)
  -i, --index=<s>           Create this index
  -a, --allow-overwrite     Allow the deletion of an existing index
  -n, --input=<s>           Read json files from this directory (default: /usr/src/esmigrationtools)
  -s, --strip-fields=<s>    Comma separated list of fields to remove before uploading (default: )
  -t, --threads=<i>         Number of processing threads to run (default: 8)
  -h, --help                Show this message
```

This is a multi-threaded version of `upload_to_new`. Functionally it's the same, but it will process multiple data pages
simultaneously controlled by the `--threads` option.
