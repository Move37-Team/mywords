class TrieNode {
  String char;
  bool isWord;
  Set<TrieNode> next = Set();

  TrieNode({this.char, this.isWord});

  static Set<TrieNode> roots = Set();

  static Set<TrieNode> makeTrieFromDict(Map<String, dynamic> _dictionary) {

    Set<TrieNode> _roots = Set();

    _dictionary.forEach((key, value) {
      var rootChar = key[0];
      TrieNode currentNode;

      try {
        currentNode = _roots.firstWhere((node) =>
        node.char == rootChar);
      } catch (E) {
        currentNode =
            TrieNode(char: rootChar, isWord: false);
        _roots.add(currentNode);
      } finally {
        if (key.length == 1)
          currentNode.isWord = true;
      }

      for (var i = 1; i < key.length; i++) {
        TrieNode nxtNode;

        try {
          nxtNode = currentNode.next.firstWhere((node) => node.char == key[i]);
        } catch (E) {
          nxtNode = TrieNode(char: key[i], isWord: false);
          currentNode.next.add(nxtNode);
        } finally {
          if (i == key.length - 1)
            nxtNode.isWord = true;

          currentNode = nxtNode;
        }
      }
    });

    return _roots;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => char.codeUnitAt(0);

  @override
  bool operator ==(other) {
    return hashCode == other.hashCode;
  }
}