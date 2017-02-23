import yaml
import json
import sys

if len(sys.argv) < 3:
    print("Usage:\n\tpython3 scripts/localizeSchema.py languageCode schemaName")
    exit()

languageCode = sys.argv[1]
schemaName   = sys.argv[2]

with open("{}/schema.yml".format(languageCode)) as f:
    translations = yaml.load(f.read())

with open("schema/{}.json".format(schemaName)) as f:
    schema = f.read()

for key in translations.keys():
    pattern = "{{ %(transKey)s }}" % {"transKey": key}
    if schema.find(pattern):
        translation = json.dumps(translations[key], ensure_ascii=False)[1:-1]
        schema = schema.replace(pattern, translation)

print(json.dumps(json.loads(schema), indent=4, ensure_ascii=False))
