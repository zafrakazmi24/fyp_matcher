class FypIdea {
  final String id;
  final String title;
  final String problem;
  final String area; // fypAreas mein se
  final String difficulty; // Beginner / Intermediate / Advanced
  final List<String> skills; // skill_dictionary ke naam
  final List<String> interests; // interestEntries ke naam
  final List<String> features;

  const FypIdea({
    required this.id,
    required this.title,
    required this.problem,
    required this.area,
    required this.difficulty,
    required this.skills,
    required this.interests,
    required this.features,
  });
}

const fypIdeas = <FypIdea>[
  // ---------------- Mobile App Development ----------------
  FypIdea(
    id: 'm1',
    title: 'Smart Campus Companion App',
    problem:
    'Students miss class changes, notices and events because information is scattered over many groups.',
    area: 'Mobile App Development',
    difficulty: 'Intermediate',
    skills: ['Flutter', 'Firebase', 'UI/UX Design', 'Git'],
    interests: ['Mobile Apps', 'Education Tech'],
    features: [
      'Live timetable and class-change alerts',
      'Campus announcements with push notifications',
      'Lost and found board with photos',
      'Complaint and feedback tracking',
    ],
  ),
  FypIdea(
    id: 'm2',
    title: 'Healthcare Appointment and Records App',
    problem:
    'Patients wait in long queues and carry paper files that are easily lost.',
    area: 'Mobile App Development',
    difficulty: 'Intermediate',
    skills: ['Flutter', 'Firebase', 'REST APIs', 'Database Design'],
    interests: ['Healthcare', 'Mobile Apps'],
    features: [
      'Doctor search and appointment booking',
      'Digital medical record storage',
      'Medicine and visit reminders',
      'Doctor and patient chat',
    ],
  ),
  FypIdea(
    id: 'm3',
    title: 'Community Blood Donor Finder',
    problem:
    'In emergencies, finding a matching blood donor nearby takes hours of phone calls.',
    area: 'Mobile App Development',
    difficulty: 'Beginner',
    skills: ['Flutter', 'Firebase', 'REST APIs'],
    interests: ['Healthcare', 'Social Impact', 'Mobile Apps'],
    features: [
      'Donor registration with blood group and city',
      'Emergency request with nearby donor alerts',
      'Donation history and eligibility timer',
      'Verified donor badges',
    ],
  ),
  FypIdea(
    id: 'm4',
    title: 'Smart Expense and Budget Tracker',
    problem:
    'Young people struggle to see where their money goes and to save regularly.',
    area: 'Mobile App Development',
    difficulty: 'Intermediate',
    skills: ['Flutter', 'SQL', 'Machine Learning', 'Data Visualization'],
    interests: ['FinTech', 'Mobile Apps'],
    features: [
      'Quick expense entry with categories',
      'Monthly budgets with overspend warnings',
      'Spending predictions using ML',
      'Charts and savings goals',
    ],
  ),

  // ---------------- Artificial Intelligence ----------------
  FypIdea(
    id: 'a1',
    title: 'AI Chatbot for University Admissions and FAQs',
    problem:
    'Admission offices answer the same questions all day and applicants wait for replies.',
    area: 'Artificial Intelligence',
    difficulty: 'Intermediate',
    skills: ['Python', 'NLP', 'Flask', 'React'],
    interests: ['Artificial Intelligence', 'NLP', 'Education Tech'],
    features: [
      'Understands student questions in plain language',
      'Answers from a managed FAQ knowledge base',
      'Hands over to staff when unsure',
      'Admin dashboard with question analytics',
    ],
  ),
  FypIdea(
    id: 'a2',
    title: 'Resume Screening and Job Matching System',
    problem:
    'Recruiters spend hours reading resumes and good candidates are overlooked.',
    area: 'Artificial Intelligence',
    difficulty: 'Intermediate',
    skills: ['Python', 'NLP', 'Scikit-learn', 'SQL'],
    interests: ['Recommender Systems', 'NLP', 'Artificial Intelligence'],
    features: [
      'Extracts skills and experience from resumes',
      'Ranks candidates against a job description',
      'Explains each score in simple words',
      'Suggests missing skills to candidates',
    ],
  ),
  FypIdea(
    id: 'a3',
    title: 'Urdu and English Fake News Detector',
    problem:
    'Misleading news spreads quickly on social media and people cannot verify it.',
    area: 'Artificial Intelligence',
    difficulty: 'Advanced',
    skills: ['Python', 'NLP', 'Scikit-learn', 'Pandas'],
    interests: ['NLP', 'Social Impact', 'Machine Learning'],
    features: [
      'Classifies a headline or article as real or suspicious',
      'Shows the words that influenced the decision',
      'Browser or mobile front end',
      'Community reporting of new fake stories',
    ],
  ),
  FypIdea(
    id: 'a4',
    title: 'Personalized Course and Study Planner',
    problem:
    'Students pick courses and study resources without guidance on what suits them.',
    area: 'Artificial Intelligence',
    difficulty: 'Beginner',
    skills: ['Python', 'Scikit-learn', 'Firebase', 'Flutter'],
    interests: ['Recommender Systems', 'Education Tech', 'Artificial Intelligence'],
    features: [
      'Course recommendations from interests and grades',
      'Weekly study plan generator',
      'Progress tracking and reminders',
      'Content-based and collaborative filtering',
    ],
  ),

  // ---------------- Machine Learning ----------------
  FypIdea(
    id: 'ml1',
    title: 'Plant Disease Detection from Leaf Photos',
    problem:
    'Farmers cannot identify crop diseases early and lose a large part of their harvest.',
    area: 'Machine Learning',
    difficulty: 'Advanced',
    skills: ['Python', 'TensorFlow', 'Computer Vision', 'Flutter'],
    interests: ['Computer Vision', 'Machine Learning', 'Social Impact'],
    features: [
      'Take a photo of a leaf in the mobile app',
      'CNN model predicts the disease',
      'Treatment advice for each disease',
      'History of scans per field',
    ],
  ),
  FypIdea(
    id: 'ml2',
    title: 'Face Recognition Attendance System',
    problem:
    'Manual attendance wastes class time and proxy attendance is common.',
    area: 'Machine Learning',
    difficulty: 'Intermediate',
    skills: ['Python', 'Computer Vision', 'Firebase', 'SQL'],
    interests: ['Computer Vision', 'Automation', 'Education Tech'],
    features: [
      'Detects and recognizes faces from a camera',
      'Marks attendance automatically',
      'Teacher reports and low-attendance alerts',
      'Student enrollment from a few photos',
    ],
  ),
  FypIdea(
    id: 'ml3',
    title: 'Student Performance Predictor and Early Warning',
    problem:
    'Teachers find out a student is struggling only after the exam results.',
    area: 'Machine Learning',
    difficulty: 'Beginner',
    skills: ['Python', 'Pandas', 'Scikit-learn', 'Data Visualization'],
    interests: ['Education Tech', 'Machine Learning', 'Data Science'],
    features: [
      'Predicts final grade from attendance and quiz marks',
      'Flags at-risk students early',
      'Class level dashboard for teachers',
      'Suggested actions for each student',
    ],
  ),

  // ---------------- Web Development ----------------
  FypIdea(
    id: 'w1',
    title: 'Online Marketplace for Local Artisans',
    problem:
    'Small craft makers have no affordable way to sell beyond their own city.',
    area: 'Web Development',
    difficulty: 'Intermediate',
    skills: ['React', 'Node.js', 'MongoDB', 'REST APIs'],
    interests: ['E-commerce', 'Web Development', 'Social Impact'],
    features: [
      'Seller shops with product listings',
      'Cart, checkout and order tracking',
      'Ratings and reviews',
      'Seller sales dashboard',
    ],
  ),
  FypIdea(
    id: 'w2',
    title: 'Online Exam and Quiz Platform with Auto Grading',
    problem:
    'Teachers lose time grading and creating quizzes, and cheating is hard to control.',
    area: 'Web Development',
    difficulty: 'Intermediate',
    skills: ['React', 'Node.js', 'SQL', 'REST APIs'],
    interests: ['Education Tech', 'Web Development', 'Automation'],
    features: [
      'Question bank and timed quizzes',
      'Automatic grading with instant results',
      'Randomised question order',
      'Result analytics for teachers',
    ],
  ),
  FypIdea(
    id: 'w3',
    title: 'Hospital Queue and Token Management',
    problem:
    'Patients crowd waiting rooms because nobody knows when their turn will come.',
    area: 'Web Development',
    difficulty: 'Beginner',
    skills: ['HTML', 'CSS', 'JavaScript', 'SQL'],
    interests: ['Healthcare', 'Web Development', 'Automation'],
    features: [
      'Online token booking per doctor',
      'Live queue screen for the waiting room',
      'SMS or web notification near the turn',
      'Reception admin panel',
    ],
  ),

  // ---------------- Data Science ----------------
  FypIdea(
    id: 'd1',
    title: 'Sales Forecasting Dashboard for Small Businesses',
    problem:
    'Shop owners stock too much or too little because they cannot predict demand.',
    area: 'Data Science',
    difficulty: 'Intermediate',
    skills: ['Python', 'Pandas', 'Machine Learning', 'Data Visualization'],
    interests: ['Data Science', 'E-commerce', 'Machine Learning'],
    features: [
      'Upload sales data as a spreadsheet',
      'Forecast of next month sales',
      'Best and worst selling product insights',
      'Interactive dashboard with charts',
    ],
  ),
  FypIdea(
    id: 'd2',
    title: 'Air Quality Analytics Dashboard',
    problem:
    'People have little local information about pollution levels and trends.',
    area: 'Data Science',
    difficulty: 'Beginner',
    skills: ['Python', 'Pandas', 'Data Visualization', 'SQL'],
    interests: ['Data Science', 'Social Impact'],
    features: [
      'Collects open air-quality data by city',
      'Trend charts and heat maps',
      'Health advice for each pollution level',
      'Alerts for unsafe days',
    ],
  ),
  FypIdea(
    id: 'd3',
    title: 'Social Media Sentiment Analysis on Public Issues',
    problem:
    'Organizations cannot measure what people actually feel about services and policies.',
    area: 'Data Science',
    difficulty: 'Intermediate',
    skills: ['Python', 'NLP', 'Pandas', 'Data Visualization'],
    interests: ['NLP', 'Data Science', 'Social Impact'],
    features: [
      'Collects public posts on a topic',
      'Classifies sentiment as positive, neutral or negative',
      'Trending keywords and timeline',
      'Downloadable summary report',
    ],
  ),

  // ---------------- Cyber Security ----------------
  FypIdea(
    id: 'c1',
    title: 'Phishing Link and Email Detector',
    problem:
    'Users lose money and accounts by clicking convincing fake links.',
    area: 'Cyber Security',
    difficulty: 'Intermediate',
    skills: ['Python', 'Machine Learning', 'JavaScript', 'Cyber Security'],
    interests: ['Cyber Security', 'Machine Learning'],
    features: [
      'Scans a URL or email text for phishing signs',
      'Risk score with simple reasons',
      'Browser extension for live warnings',
      'Report and block list',
    ],
  ),
  FypIdea(
    id: 'c2',
    title: 'Secure Password Manager App',
    problem:
    'People reuse weak passwords because remembering many strong ones is hard.',
    area: 'Cyber Security',
    difficulty: 'Beginner',
    skills: ['Flutter', 'Cyber Security', 'Firebase'],
    interests: ['Cyber Security', 'Mobile Apps'],
    features: [
      'Encrypted password vault',
      'Strong password generator',
      'Weak and reused password check',
      'Biometric unlock',
    ],
  ),
  FypIdea(
    id: 'c3',
    title: 'Network Intrusion Detection using ML',
    problem:
    'Small organizations cannot afford security analysts to watch network traffic.',
    area: 'Cyber Security',
    difficulty: 'Advanced',
    skills: ['Python', 'Networking', 'Machine Learning', 'Cyber Security'],
    interests: ['Cyber Security', 'Machine Learning'],
    features: [
      'Analyzes network traffic records',
      'Detects suspicious activity automatically',
      'Live alert dashboard',
      'Attack type classification',
    ],
  ),

  // ---------------- IoT / Embedded Systems ----------------
  FypIdea(
    id: 'i1',
    title: 'Smart Home Energy Monitor',
    problem:
    'Households get high electricity bills without knowing which appliance wastes power.',
    area: 'IoT / Embedded Systems',
    difficulty: 'Intermediate',
    skills: ['Arduino', 'IoT', 'Embedded Systems', 'Flutter'],
    interests: ['IoT', 'Automation'],
    features: [
      'Sensors measure power use per appliance',
      'Live usage in a mobile app',
      'Daily and monthly cost estimate',
      'Remote on/off control',
    ],
  ),
  FypIdea(
    id: 'i2',
    title: 'Smart Irrigation System',
    problem:
    'Farmers waste water and crops suffer because watering is based on guesswork.',
    area: 'IoT / Embedded Systems',
    difficulty: 'Intermediate',
    skills: ['Arduino', 'IoT', 'Raspberry Pi', 'Firebase'],
    interests: ['IoT', 'Automation', 'Social Impact'],
    features: [
      'Soil moisture and weather sensing',
      'Automatic pump control',
      'Mobile app with field status',
      'Water usage reports',
    ],
  ),
  FypIdea(
    id: 'i3',
    title: 'Smart Waste Bin Monitoring',
    problem:
    'Garbage trucks follow fixed routes while some bins overflow and others are empty.',
    area: 'IoT / Embedded Systems',
    difficulty: 'Beginner',
    skills: ['Arduino', 'IoT', 'Firebase', 'Flutter'],
    interests: ['IoT', 'Social Impact', 'Automation'],
    features: [
      'Ultrasonic sensor measures bin fill level',
      'Dashboard showing full bins on a map',
      'Alert to collectors',
      'Optimised collection route',
    ],
  ),

  // ---------------- Game Development ----------------
  FypIdea(
    id: 'g1',
    title: 'Educational Game for Kids (Urdu and Maths)',
    problem:
    'Young children find textbook learning boring and lose interest quickly.',
    area: 'Game Development',
    difficulty: 'Beginner',
    skills: ['Unity', 'C#', 'UI/UX Design'],
    interests: ['Game Development', 'Education Tech'],
    features: [
      'Levels for Urdu letters and basic maths',
      'Rewards, stars and characters',
      'Progress report for parents',
      'Voice and sound feedback',
    ],
  ),
  FypIdea(
    id: 'g2',
    title: 'AR Campus Navigation',
    problem:
    'New students and visitors get lost finding classrooms and offices.',
    area: 'Game Development',
    difficulty: 'Advanced',
    skills: ['Unity', 'C#', 'Android'],
    interests: ['AR/VR', 'Mobile Apps'],
    features: [
      'Camera view with direction arrows',
      'Search for any room or department',
      'Indoor and outdoor guidance',
      'Event and notice overlays',
    ],
  ),

  // ---------------- Cloud Computing ----------------
  FypIdea(
    id: 'cl1',
    title: 'Cloud-based Inventory SaaS for Small Shops',
    problem:
    'Small shops track stock on paper and cannot afford expensive software.',
    area: 'Cloud Computing',
    difficulty: 'Intermediate',
    skills: ['Node.js', 'MongoDB', 'Docker', 'AWS'],
    interests: ['Cloud Computing', 'Web Development', 'E-commerce'],
    features: [
      'Multi-shop accounts hosted in the cloud',
      'Stock in, stock out and low-stock alerts',
      'Sales reports',
      'Automated deployment with Docker',
    ],
  ),
  FypIdea(
    id: 'cl2',
    title: 'Blockchain-based Certificate Verification',
    problem:
    'Fake degrees and certificates are hard to detect and verification takes weeks.',
    area: 'Cloud Computing',
    difficulty: 'Advanced',
    skills: ['Blockchain', 'JavaScript', 'Node.js'],
    interests: ['Blockchain', 'Education Tech'],
    features: [
      'Institutes issue tamper-proof certificates',
      'Employers verify with a QR code',
      'Revocation support',
      'Issuer dashboard',
    ],
  ),
];