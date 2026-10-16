import '../core/skill_dictionary.dart';

class NlpResult {
  final List<String> skills;
  final List<String> interests;
  final String? suggestedArea;

  NlpResult({
    required this.skills,
    required this.interests,
    required this.suggestedArea,
  });

  bool get isEmpty =>
      skills.isEmpty && interests.isEmpty && suggestedArea == null;
}

class NlpService {
  // Dictionary ke patterns sirf ek dafa bante hain
  static final Map<String, List<RegExp>> _skillPatterns =
  _build(skillEntries);
  static final Map<String, List<RegExp>> _interestPatterns =
  _build(interestEntries);

  static Map<String, List<RegExp>> _build(List<DictEntry> entries) => {
    for (final e in entries)
      e.name: e.aliases.map(_pattern).toList(),
  };

  // Word-boundary jo c++, c#, .net, node.js jaise aliases ke saath bhi chale
  static RegExp _pattern(String alias) {
    final esc = RegExp.escape(alias);
    final before =
    alias.startsWith('.') ? r'(?<![a-z0-9+#])' : r'(?<![a-z0-9+#.])';
    return RegExp('$before$esc(?![a-z0-9+#])');
  }

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[\u2018\u2019]'), "'")
      .replaceAll(RegExp(r'\s+'), ' ');

  static int _mentions(List<RegExp> patterns, String text) {
    var count = 0;
    for (final p in patterns) {
      count += p.allMatches(text).length;
    }
    return count;
  }

  /// Free text se skills, interests aur suggested FYP area nikalta hai.
  static NlpResult analyze(String rawText) {
    final text = _normalize(rawText);
    if (text.trim().isEmpty) {
      return NlpResult(skills: [], interests: [], suggestedArea: null);
    }

    final areaScore = <String, int>{};
    void addScore(String? area, int n) {
      if (area == null) return;
      areaScore[area] = (areaScore[area] ?? 0) + n;
    }

    final skills = <String>[];
    for (final e in skillEntries) {
      final n = _mentions(_skillPatterns[e.name]!, text);
      if (n > 0) {
        skills.add(e.name);
        addScore(e.area, n);
      }
    }

    final interests = <String>[];
    for (final e in interestEntries) {
      final n = _mentions(_interestPatterns[e.name]!, text);
      if (n > 0) {
        interests.add(e.name);
        addScore(e.area, n * 2); // interest ka wazan zyada
      }
    }

    String? best;
    var bestScore = 0;
    areaScore.forEach((area, score) {
      if (score > bestScore) {
        best = area;
        bestScore = score;
      }
    });

    return NlpResult(
        skills: skills, interests: interests, suggestedArea: best);
  }
}