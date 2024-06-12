Feature: Artifacts

    Scenario: Create and use artifact from single file
        Given a source file "foobar.json":
            """
            {
                "foo": "bar"
            }
            """
        When artifact "JSON" is created for file "foobar.json"
        And artifact "JSON" is used
        Then the restored file "foobar.json" should match its source

    Scenario: Non-existant paths create empty archives
        When artifact "EMPTY" is created for file "nonexistant"
        And artifact "EMPTY" is used
        Then there are no restored files

    Scenario: Artifacts containing multiple files
       Given files:
        | path               | content |
        | source/a/a1.txt    | A one   |
        | source/a/a2.txt    | A one   |
        | blarg/b/b1.txt     | B one   |
        | source/c/d/e/f.txt | File    |
        When artifact "SOURCES" is created for path "/source"
        Then artifact "SOURCES" contains:
        | path        | content |
        | a/a1.txt    | A one   |
        | a/a2.txt    | A one   |
        | c/d/e/f.txt | File    |
