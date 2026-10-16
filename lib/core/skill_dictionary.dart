class DictEntry {
  final String name;
  final List<String> aliases;
  final String? area; // fypAreas mein se koi ek
  const DictEntry(this.name, this.aliases, [this.area]);
}

const _mobile = 'Mobile App Development';
const _web = 'Web Development';
const _ai = 'Artificial Intelligence';
const _ml = 'Machine Learning';
const _data = 'Data Science';
const _cyber = 'Cyber Security';
const _iot = 'IoT / Embedded Systems';
const _game = 'Game Development';
const _cloud = 'Cloud Computing';

const skillEntries = <DictEntry>[
  // Mobile
  DictEntry('Flutter', ['flutter'], _mobile),
  DictEntry('Dart', ['dart'], _mobile),
  DictEntry('Firebase', ['firebase', 'firestore'], _mobile),
  DictEntry('Android', ['android', 'android studio'], _mobile),
  DictEntry('Kotlin', ['kotlin'], _mobile),
  DictEntry('Swift', ['swift', 'swiftui'], _mobile),
  DictEntry('React Native', ['react native'], _mobile),

  // Web
  DictEntry('HTML', ['html', 'html5'], _web),
  DictEntry('CSS', ['css', 'css3'], _web),
  DictEntry('JavaScript', ['javascript', 'js', 'ecmascript'], _web),
  DictEntry('TypeScript', ['typescript'], _web),
  DictEntry('React', ['react', 'reactjs', 'react.js'], _web),
  DictEntry('Angular', ['angular', 'angularjs'], _web),
  DictEntry('Vue.js', ['vue', 'vuejs', 'vue.js'], _web),
  DictEntry('Node.js', ['node', 'nodejs', 'node.js'], _web),
  DictEntry('Express.js', ['express', 'expressjs', 'express.js'], _web),
  DictEntry('Tailwind CSS', ['tailwind', 'tailwindcss'], _web),
  DictEntry('Bootstrap', ['bootstrap'], _web),
  DictEntry('PHP', ['php'], _web),
  DictEntry('Laravel', ['laravel'], _web),
  DictEntry('Django', ['django'], _web),
  DictEntry('Flask', ['flask'], _web),
  DictEntry('FastAPI', ['fastapi'], _web),
  DictEntry('Spring Boot', ['spring boot', 'springboot', 'spring'], _web),
  DictEntry('.NET', ['.net', 'dotnet', 'asp.net'], _web),
  DictEntry('REST APIs', ['rest', 'rest api', 'rest apis', 'restful', 'api', 'apis'], _web),
  DictEntry('GraphQL', ['graphql'], _web),

  // Programming languages
  DictEntry('Python', ['python'], _ml),
  DictEntry('Java', ['java']),
  DictEntry('C++', ['c++', 'cpp']),
  DictEntry('C#', ['c#', 'csharp']),
  DictEntry('C', ['c language', 'c programming']),
  DictEntry('R', ['r language', 'r programming']),

  // Databases
  DictEntry('SQL', ['sql', 'sql server']),
  DictEntry('MySQL', ['mysql']),
  DictEntry('PostgreSQL', ['postgresql', 'postgres']),
  DictEntry('MongoDB', ['mongodb', 'mongo']),
  DictEntry('Database Design', ['database design', 'erd', 'er diagram', 'normalization']),

  // AI / ML / Data
  DictEntry('Machine Learning', ['machine learning', 'ml'], _ml),
  DictEntry('Deep Learning', ['deep learning', 'neural network', 'neural networks', 'cnn', 'lstm'], _ml),
  DictEntry('NLP', ['nlp', 'natural language processing', 'text mining', 'text analysis'], _ai),
  DictEntry('Computer Vision', ['computer vision', 'opencv', 'image processing', 'object detection'], _ml),
  DictEntry('TensorFlow', ['tensorflow', 'keras'], _ml),
  DictEntry('PyTorch', ['pytorch'], _ml),
  DictEntry('Scikit-learn', ['scikit-learn', 'scikit learn', 'sklearn'], _ml),
  DictEntry('Pandas', ['pandas'], _data),
  DictEntry('NumPy', ['numpy'], _data),
  DictEntry('Data Analysis', ['data analysis', 'data analytics'], _data),
  DictEntry('Data Visualization', ['data visualization', 'data visualisation', 'power bi', 'tableau', 'matplotlib'], _data),

  // Cloud / DevOps
  DictEntry('Git', ['git', 'github', 'gitlab', 'version control']),
  DictEntry('Docker', ['docker'], _cloud),
  DictEntry('Kubernetes', ['kubernetes', 'k8s'], _cloud),
  DictEntry('AWS', ['aws', 'amazon web services'], _cloud),
  DictEntry('Azure', ['azure'], _cloud),
  DictEntry('Google Cloud', ['google cloud', 'gcp'], _cloud),
  DictEntry('Linux', ['linux', 'ubuntu']),

  // Security / Networking
  DictEntry('Cyber Security', ['cyber security', 'cybersecurity', 'ethical hacking', 'penetration testing', 'network security', 'information security'], _cyber),
  DictEntry('Networking', ['networking', 'computer networks', 'cisco', 'tcp/ip'], _cyber),

  // IoT / Hardware
  DictEntry('Arduino', ['arduino'], _iot),
  DictEntry('Raspberry Pi', ['raspberry pi'], _iot),
  DictEntry('IoT', ['iot', 'internet of things'], _iot),
  DictEntry('Embedded Systems', ['embedded', 'embedded systems', 'microcontroller', 'microcontrollers'], _iot),

  // Game
  DictEntry('Unity', ['unity', 'unity3d'], _game),
  DictEntry('Unreal Engine', ['unreal', 'unreal engine'], _game),

  // Design
  DictEntry('UI/UX Design', ['ui/ux', 'ui ux', 'ux', 'ui design', 'ux design', 'user interface', 'user experience']),
  DictEntry('Figma', ['figma']),
  DictEntry('Adobe XD', ['adobe xd']),
  DictEntry('Photoshop', ['photoshop']),

  // Process / Team
  DictEntry('Software Testing', ['software testing', 'manual testing', 'selenium', 'qa', 'quality assurance', 'test cases', 'unit testing']),
  DictEntry('System Design', ['system design', 'software architecture', 'uml']),
  DictEntry('Agile/Scrum', ['agile', 'scrum']),
  DictEntry('Project Management', ['project management', 'project manager']),
  DictEntry('Technical Writing', ['technical writing', 'documentation', 'report writing']),
  DictEntry('Blockchain', ['blockchain', 'solidity', 'smart contracts', 'web3'], _cloud),
  DictEntry('Leadership', ['leadership', 'team lead', 'team leader']),
  DictEntry('Communication', ['communication skills', 'public speaking', 'presentation skills']),
];

const interestEntries = <DictEntry>[
  DictEntry('Artificial Intelligence', ['ai', 'artificial intelligence', 'chatbot', 'chatbots', 'intelligent systems'], _ai),
  DictEntry('Machine Learning', ['machine learning', 'ml', 'predictive model', 'predictive models'], _ml),
  DictEntry('NLP', ['nlp', 'natural language processing', 'text mining'], _ai),
  DictEntry('Computer Vision', ['computer vision', 'image recognition', 'face recognition', 'object detection'], _ml),
  DictEntry('Recommender Systems', ['recommender', 'recommendation system', 'recommendation systems', 'recommendation'], _ml),
  DictEntry('Mobile Apps', ['mobile app', 'mobile apps', 'mobile application', 'mobile applications', 'app development', 'android app', 'ios app'], _mobile),
  DictEntry('Web Development', ['web development', 'website', 'websites', 'web app', 'web apps', 'full stack', 'full-stack', 'frontend', 'backend'], _web),
  DictEntry('Data Science', ['data science', 'big data', 'data mining', 'analytics'], _data),
  DictEntry('Cyber Security', ['cyber security', 'cybersecurity', 'ethical hacking', 'network security', 'privacy'], _cyber),
  DictEntry('IoT', ['iot', 'internet of things', 'smart home', 'sensors', 'embedded'], _iot),
  DictEntry('Robotics', ['robotics', 'robot', 'robots'], _iot),
  DictEntry('Game Development', ['game development', 'game design', 'games', 'gaming'], _game),
  DictEntry('Cloud Computing', ['cloud', 'cloud computing', 'serverless'], _cloud),
  DictEntry('Blockchain', ['blockchain', 'cryptocurrency', 'smart contracts'], _cloud),
  DictEntry('Healthcare', ['healthcare', 'health care', 'medical', 'hospital']),
  DictEntry('Education Tech', ['education', 'e-learning', 'elearning', 'edtech', 'learning platform']),
  DictEntry('E-commerce', ['e-commerce', 'ecommerce', 'online shopping', 'online store']),
  DictEntry('FinTech', ['fintech', 'banking', 'payment', 'payments', 'finance']),
  DictEntry('Automation', ['automation', 'automate', 'workflow']),
  DictEntry('AR/VR', ['ar', 'vr', 'augmented reality', 'virtual reality']),
  DictEntry('UI/UX Design', ['ui/ux', 'user experience', 'ux', 'design thinking']),
  DictEntry('Social Impact', ['social impact', 'ngo', 'community', 'social good']),
];