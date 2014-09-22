HTMLBook Backends
=================

This repo holds the backend templates for converting `.asciidoc` files into `.html` files in the htmlbook flavor. The repo ships with 2 backends:

- `htmlbook` - a set of templates that can be used directly with the `asciidoctor` gem. This is a direct source conversion
- `htmlbook-autogen` - a set of templates that can only be used with the `orm_asciidoctor` gem. This provides some autogeneration abilities.

One-time Conversion of Books
----------------------------

In this folder there's a script that helps you convert book files written in asciidoc into htmlbook. Before you run it, it assumes you have installed the `asciidoctor` gem.

Convert a book by running the script like this:

```bash
$ ruby scripts/convert_folder PATH_TO_BOOK_REPO
```

So If my book repo exists in `/Documents/MyBook`, you would do the following:

```bash
$ ruby scripts/convert_book.rb /Documents/MyBook
```
