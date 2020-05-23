# MyWords
Simple English Dictionary Based on Webster's Unabridged English Dictionary With Identicons for each word and 
a light weight utility to save your favorite words, in Flutter!

# Getting Started

clone the repository
```
git clone https://github.com/Move37-Team/mywords.git
```

install the requirements
```
flutter pub get
```

# Dictionary files

Two dictionary files are used in this project. both are in json format.

```assets/dictionary_web.json``` is the Webster's Unabridged English Dictionary in json format with the following structure:

```
{
    "word": "Meaning"
}
```

```assets/trie_dict.json``` is a list of all words in the above file but trie data structure

sample
```
{
    "w": {
            "o": {
                    "r": {
                            "d" : {
                                    "_end_": "_end_"
                                  }
                         }
                 }
        }
}
```

```assets/synonyms_dict.json``` a dictionary of word synonyms

```
{
    "word": "comma separated list of synonyms as a string"
}
```

# Acknowledgments

- Webster's Unabridged English Dictionary provided by [Project Gutenberg](https://www.gutenberg.org/ebooks/29765)
- ```dictionary_web.json``` file provided by [this repo](https://github.com/matthewreagan/WebstersEnglishDictionary)
- ```synonyms_dict.json``` scrapped from [WordNet](https://wordnet.princeton.edu/)

***if you make any changes, improvements or bug fixes please consider a PR***

# Road Map

* [ ] categorize words

* [x] add dictionary

* [ ] custom word with custom definition

* [x] autocomplete
 
* [ ] multiple language support
 
* [ ] cloud backend
