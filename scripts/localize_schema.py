#!/usr/bin/env python3

import argparse
import collections
import json


def localize_schema(translations_file, schema_file):
    schema = schema_file.read()

    with open(translations_file) as f:
        translations = {i.split(": ")[0]: i.split(": ")[1] for i in f.readlines()}

    for key in translations.keys():
        pattern = "{{ " + key + " }}"  # Avoid mixing python's and our own template language
        if schema.find(pattern):
            translation = json.dumps(translations[key], ensure_ascii=False)[1:-1]
            schema = schema.replace(pattern, translation)

    return json.loads(schema, object_pairs_hook=collections.OrderedDict)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("translations_file")
    parser.add_argument("schema_name")
    args = parser.parse_args()
    with open("schema/{}.json".format(args.schema_name)) as schema_name:
        localized = localize_schema(args.translations_file, schema_name)
    print(json.dumps(localized, indent=4, ensure_ascii=False))

