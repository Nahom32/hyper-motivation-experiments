!(import! &self "converter.py")

(= (dummyFunc $name)
    (let $values (py-call (converter.file_to_s_expression $name)) $values)
)


!(dummyFunc "/Users/nahomsenay/projects/hyper-motivation-experiments/utils/dummy_json_samples.json")
