import 'skill_dictionary.dart';

const skillGroups = <String, List<String>>{
  'Frontend': [
    'Flutter', 'Dart', 'React', 'Angular', 'Vue.js', 'HTML', 'CSS',
    'JavaScript', 'TypeScript', 'Tailwind CSS', 'Bootstrap', 'Android',
    'Kotlin', 'Swift', 'React Native'
  ],
  'Backend': [
    'Node.js', 'Express.js', 'Django', 'Flask', 'FastAPI', 'Spring Boot',
    '.NET', 'PHP', 'Laravel', 'Java', 'Python', 'C#', 'Firebase',
    'REST APIs', 'GraphQL'
  ],
  'Database': [
    'SQL', 'MySQL', 'PostgreSQL', 'MongoDB', 'Database Design', 'Firebase'
  ],
  'AI / ML': [
    'Machine Learning', 'Deep Learning', 'NLP', 'Computer Vision',
    'TensorFlow', 'PyTorch', 'Scikit-learn'
  ],
  'Data & Analytics': [
    'Pandas', 'NumPy', 'Data Analysis', 'Data Visualization', 'SQL', 'Python'
  ],
  'UI/UX Design': ['UI/UX Design', 'Figma', 'Adobe XD', 'Photoshop'],
  'Testing & QA': ['Software Testing'],
  'Documentation & PM': [
    'Technical Writing', 'Project Management', 'Agile/Scrum',
    'System Design', 'Leadership', 'Communication'
  ],
  'DevOps / Cloud': [
    'Git', 'Docker', 'Kubernetes', 'AWS', 'Azure', 'Google Cloud', 'Linux'
  ],
  'Security': ['Cyber Security', 'Networking'],
  'Hardware / IoT': ['Arduino', 'Raspberry Pi', 'IoT', 'Embedded Systems'],
  'Game Engine': ['Unity', 'Unreal Engine', 'C#', 'C++'],
};

// Har FYP area ke liye zaroori skill groups
const areaRequirements = <String, List<String>>{
  'Artificial Intelligence': [
    'AI / ML', 'Backend', 'Frontend', 'Database', 'Testing & QA'
  ],
  'Machine Learning': [
    'AI / ML', 'Data & Analytics', 'Backend', 'Frontend',
    'Documentation & PM'
  ],
  'Web Development': [
    'Frontend', 'Backend', 'Database', 'UI/UX Design', 'Testing & QA'
  ],
  'Mobile App Development': [
    'Frontend', 'Backend', 'Database', 'UI/UX Design', 'Testing & QA'
  ],
  'Data Science': [
    'Data & Analytics', 'AI / ML', 'Database', 'Frontend',
    'Documentation & PM'
  ],
  'Cyber Security': [
    'Security', 'Backend', 'Database', 'DevOps / Cloud',
    'Documentation & PM'
  ],
  'IoT / Embedded Systems': [
    'Hardware / IoT', 'Backend', 'Frontend', 'Database', 'Testing & QA'
  ],
  'Game Development': [
    'Game Engine', 'UI/UX Design', 'Backend', 'Testing & QA',
    'Documentation & PM'
  ],
  'Cloud Computing': [
    'DevOps / Cloud', 'Backend', 'Database', 'Frontend', 'Security'
  ],
  'Other': [
    'Frontend', 'Backend', 'Database', 'UI/UX Design', 'Documentation & PM'
  ],
};

// Kisi group mein skill na ho to pehle ye seekhni chahiye
const groupStarters = <String, List<String>>{
  'Frontend': ['Flutter', 'React'],
  'Backend': ['Node.js', 'Firebase'],
  'Database': ['SQL', 'MongoDB'],
  'AI / ML': ['Machine Learning', 'Scikit-learn'],
  'Data & Analytics': ['Pandas', 'Data Analysis'],
  'UI/UX Design': ['Figma', 'UI/UX Design'],
  'Testing & QA': ['Software Testing'],
  'Documentation & PM': ['Technical Writing', 'Agile/Scrum'],
  'DevOps / Cloud': ['Git', 'Docker'],
  'Security': ['Cyber Security', 'Networking'],
  'Hardware / IoT': ['Arduino', 'IoT'],
  'Game Engine': ['Unity'],
};

const groupTips = <String, String>{
  'Frontend':
  'Build one small screen of your FYP end to end, then add state management.',
  'Backend':
  'Create a small API or Firebase service for one feature of your FYP.',
  'Database':
  'Design the tables/collections of your FYP on paper, then implement them.',
  'AI / ML':
  'Train a simple model on a public dataset first, then connect it to your app.',
  'Data & Analytics':
  'Practise cleaning and visualising a real dataset with a notebook.',
  'UI/UX Design':
  'Make wireframes of your main screens in Figma before coding.',
  'Testing & QA':
  'Write test cases for each module and test every release on a real device.',
  'Documentation & PM':
  'Keep a weekly task board and write documentation as you build, not at the end.',
  'DevOps / Cloud':
  'Use Git branches for the team and set up a simple deployment.',
  'Security':
  'Learn the basics of authentication, encryption and common attacks.',
  'Hardware / IoT':
  'Start with one sensor and read its data before building the full system.',
  'Game Engine':
  'Follow a beginner project in the engine, then prototype your own idea.',
  'General':
  'Learn it with the official docs and use it in a small feature of your FYP.',
};

// Agar student kisi skill mein strong hai to ye related skills bhi chahiye
const relatedSkills = <String, List<String>>{
  'Flutter': ['Firebase', 'REST APIs', 'Git', 'UI/UX Design'],
  'Dart': ['Flutter', 'Firebase'],
  'Android': ['Kotlin', 'Firebase'],
  'React': ['JavaScript', 'TypeScript', 'REST APIs', 'Node.js'],
  'JavaScript': ['React', 'Node.js', 'TypeScript'],
  'HTML': ['CSS', 'JavaScript'],
  'CSS': ['JavaScript', 'Tailwind CSS'],
  'Node.js': ['MongoDB', 'Express.js', 'REST APIs'],
  'Python': ['Pandas', 'Scikit-learn', 'Flask'],
  'Machine Learning': ['Python', 'Pandas', 'Scikit-learn', 'Data Visualization'],
  'Scikit-learn': ['Pandas', 'NumPy'],
  'TensorFlow': ['Python', 'Deep Learning', 'NumPy'],
  'NLP': ['Python', 'Machine Learning', 'PyTorch'],
  'Django': ['SQL', 'REST APIs'],
  'Flask': ['SQL', 'REST APIs'],
  'Java': ['Spring Boot', 'SQL'],
  'Spring Boot': ['SQL', 'REST APIs'],
  'SQL': ['Database Design'],
  'Firebase': ['Database Design', 'REST APIs'],
  'Figma': ['UI/UX Design'],
  'UI/UX Design': ['Figma'],
  'Docker': ['Linux', 'Git', 'AWS'],
  'Cyber Security': ['Networking', 'Linux'],
  'Arduino': ['IoT', 'Embedded Systems'],
  'Unity': ['C#'],
};

// ---------------- helpers ----------------

/// "js", "JS", "javascript" sab ko ek hi naam (JavaScript) bana deta hai.
String canonicalSkill(String s) {
  final l = s.trim().toLowerCase();
  for (final e in skillEntries) {
    if (e.name.toLowerCase() == l || e.aliases.contains(l)) return e.name;
  }
  return s.trim();
}

final _groupSets = <String, Set<String>>{
  for (final e in skillGroups.entries)
    e.key: e.value.map((s) => s.toLowerCase()).toSet(),
};

int groupCount(Iterable<String> skills, String group) {
  final set = _groupSets[group] ?? <String>{};
  return skills
      .map((s) => canonicalSkill(s).toLowerCase())
      .toSet()
      .where(set.contains)
      .length;
}

bool hasGroup(Iterable<String> skills, String group) =>
    groupCount(skills, group) > 0;

String? groupOfSkill(String skill) {
  final l = canonicalSkill(skill).toLowerCase();
  for (final e in _groupSets.entries) {
    if (e.value.contains(l)) return e.key;
  }
  return null;
}