HTMLBook Backends
=================

This repo holds the backend templates for converting `.asciidoc` files into `.html` files in the htmlbook flavor.


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