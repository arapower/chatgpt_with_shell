# Count Token

This is a Node.js script that counts the number of tokens in a given text string or file path. The script uses the `gpt-3-encoder` library to encode the input text and count the number of resulting tokens.

## Usage

To use the script, run `token_counter.sh` with one of the following options:

- To count the tokens in a text string: `./token_counter.sh "text string"`
- To count the tokens in a file: `./token_counter.sh -f /path/to/file`

The output will be the number of tokens in the input text or file.

## Requirements

- Node.js v14 or higher
- NPM (Node.js Package Manager)

## Installation

1. Clone this repository or download the ZIP file and extract it.
2. Open a terminal and navigate to the directory where the script is located.
3. Run `npm install` to install the required dependencies.

## Examples

Counting the tokens in a text string:

```
$ ./token_counter.sh "This is an example text string."
7
```

Counting the tokens in a file:

```
$ ./token_counter.sh -f example.txt
17
```

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
