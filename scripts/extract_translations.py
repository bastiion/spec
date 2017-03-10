import argparse
import collections
import json
import os


def exctract_descriptions(path, schema, mappings_file):
    """
    Recursively extracts description the descriptions for translation. Left here for documentation purposes
    """
    if type(schema) != collections.OrderedDict:
        return

    for i, j in schema.items():
        if i == "description" and type(j) == str:
            fullpath = path + "." + i
            mappings_file.writelines(fullpath + ": " + j.replace("\n", "\\n") + "\n")
            schema["description"] = "{{ " + fullpath + " }}"
        exctract_descriptions(path + "." + i, j, mappings_file)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--lang", default="de")
    args = parser.parse_args()

    with open(os.path.join(args.lang, "schema.yml"), 'w') as mappings_file:
        for i in os.listdir("schema"):
            with open(os.path.join("schema", i)) as f:
                schema = json.load(f, object_pairs_hook=collections.OrderedDict)

            exctract_descriptions(i.split(".")[0], schema, mappings_file)
            with open(os.path.join("schema", i), 'w') as f:
                json.dump(schema, f, indent=4, ensure_ascii=False)


if __name__ == '__main__':
    main()
