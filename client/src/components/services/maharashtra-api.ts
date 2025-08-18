// Maharashtra Districts and Talukas API Service
// Using external APIs to fetch Maharashtra administrative data

export interface Taluka {
    id: string;
    name: string;
    districtId: string;
  }
  
  export interface District {
    id: string;
    name: string;
    talukas: Taluka[];
  }
  
  // Using GitHub raw data as external API
  const DISTRICTS_API_URL = 'https://raw.githubusercontent.com/datameet/indian_village_boundaries/master/district/maharashtra_district.json';
  
  // Fallback static data in case external API fails
  const MAHARASHTRA_DISTRICTS: District[] = [
    {
      id: "ahmednagar",
      name: "Ahmednagar",
      talukas: [
        { id: "ahmednagar_city", name: "Ahmednagar", districtId: "ahmednagar" },
        { id: "akole", name: "Akole", districtId: "ahmednagar" },
        { id: "jamkhed", name: "Jamkhed", districtId: "ahmednagar" },
        { id: "karjat", name: "Karjat", districtId: "ahmednagar" },
        { id: "kopargaon", name: "Kopargaon", districtId: "ahmednagar" },
        { id: "newasa", name: "Newasa", districtId: "ahmednagar" },
        { id: "parner", name: "Parner", districtId: "ahmednagar" },
        { id: "pathardi", name: "Pathardi", districtId: "ahmednagar" },
        { id: "rahata", name: "Rahata", districtId: "ahmednagar" },
        { id: "rahuri", name: "Rahuri", districtId: "ahmednagar" },
        { id: "sangamner", name: "Sangamner", districtId: "ahmednagar" },
        { id: "shevgaon", name: "Shevgaon", districtId: "ahmednagar" },
        { id: "shrirampur", name: "Shrirampur", districtId: "ahmednagar" },
        { id: "shrigonda", name: "Shrigonda", districtId: "ahmednagar" }
      ]
    },
    {
      id: "akola",
      name: "Akola",
      talukas: [
        { id: "akola_city", name: "Akola", districtId: "akola" },
        { id: "akot", name: "Akot", districtId: "akola" },
        { id: "balapur", name: "Balapur", districtId: "akola" },
        { id: "barshitakli", name: "Barshitakli", districtId: "akola" },
        { id: "murtijapur", name: "Murtijapur", districtId: "akola" },
        { id: "patur", name: "Patur", districtId: "akola" },
        { id: "telhara", name: "Telhara", districtId: "akola" }
      ]
    },
    {
      id: "amravati",
      name: "Amravati",
      talukas: [
        { id: "amravati_city", name: "Amravati", districtId: "amravati" },
        { id: "achalpur", name: "Achalpur", districtId: "amravati" },
        { id: "anjangaon_surji", name: "Anjangaon Surji", districtId: "amravati" },
        { id: "bhatkuli", name: "Bhatkuli", districtId: "amravati" },
        { id: "chandur_bazar", name: "Chandur Bazar", districtId: "amravati" },
        { id: "chandur_railway", name: "Chandur Railway", districtId: "amravati" },
        { id: "chikhaldara", name: "Chikhaldara", districtId: "amravati" },
        { id: "daryapur", name: "Daryapur", districtId: "amravati" },
        { id: "dharni", name: "Dharni", districtId: "amravati" },
        { id: "dhamangaon_railway", name: "Dhamangaon Railway", districtId: "amravati" },
        { id: "morshi", name: "Morshi", districtId: "amravati" },
        { id: "nandgaon_khandeshwar", name: "Nandgaon Khandeshwar", districtId: "amravati" },
        { id: "teosa", name: "Teosa", districtId: "amravati" },
        { id: "warud", name: "Warud", districtId: "amravati" }
      ]
    },
    {
      id: "aurangabad",
      name: "Aurangabad",
      talukas: [
        { id: "aurangabad_city", name: "Aurangabad", districtId: "aurangabad" },
        { id: "gangapur", name: "Gangapur", districtId: "aurangabad" },
        { id: "kannad", name: "Kannad", districtId: "aurangabad" },
        { id: "khultabad", name: "Khultabad", districtId: "aurangabad" },
        { id: "paithan", name: "Paithan", districtId: "aurangabad" },
        { id: "phulambri", name: "Phulambri", districtId: "aurangabad" },
        { id: "sillod", name: "Sillod", districtId: "aurangabad" },
        { id: "soegaon", name: "Soegaon", districtId: "aurangabad" },
        { id: "vaijapur", name: "Vaijapur", districtId: "aurangabad" }
      ]
    },
    {
      id: "beed",
      name: "Beed",
      talukas: [
        { id: "beed_city", name: "Beed", districtId: "beed" },
        { id: "ambajogai", name: "Ambajogai", districtId: "beed" },
        { id: "ashti", name: "Ashti", districtId: "beed" },
        { id: "dharur", name: "Dharur", districtId: "beed" },
        { id: "georai", name: "Georai", districtId: "beed" },
        { id: "kaij", name: "Kaij", districtId: "beed" },
        { id: "majalgaon", name: "Majalgaon", districtId: "beed" },
        { id: "parli", name: "Parli", districtId: "beed" },
        { id: "patoda", name: "Patoda", districtId: "beed" },
        { id: "shirur_kasar", name: "Shirur Kasar", districtId: "beed" },
        { id: "wadwani", name: "Wadwani", districtId: "beed" }
      ]
    },
    {
      id: "bhandara",
      name: "Bhandara",
      talukas: [
        { id: "bhandara_city", name: "Bhandara", districtId: "bhandara" },
        { id: "lakhandur", name: "Lakhandur", districtId: "bhandara" },
        { id: "mohadi", name: "Mohadi", districtId: "bhandara" },
        { id: "pauni", name: "Pauni", districtId: "bhandara" },
        { id: "sakoli", name: "Sakoli", districtId: "bhandara" },
        { id: "tumsar", name: "Tumsar", districtId: "bhandara" }
      ]
    },
    {
      id: "buldhana",
      name: "Buldhana",
      talukas: [
        { id: "buldhana_city", name: "Buldhana", districtId: "buldhana" },
        { id: "chikhli", name: "Chikhli", districtId: "buldhana" },
        { id: "deolgaon_raja", name: "Deolgaon Raja", districtId: "buldhana" },
        { id: "jalgaon_jamod", name: "Jalgaon Jamod", districtId: "buldhana" },
        { id: "khamgaon", name: "Khamgaon", districtId: "buldhana" },
        { id: "lonar", name: "Lonar", districtId: "buldhana" },
        { id: "malkapur", name: "Malkapur", districtId: "buldhana" },
        { id: "mehkar", name: "Mehkar", districtId: "buldhana" },
        { id: "motala", name: "Motala", districtId: "buldhana" },
        { id: "nandura", name: "Nandura", districtId: "buldhana" },
        { id: "sangrampur", name: "Sangrampur", districtId: "buldhana" },
        { id: "shegaon", name: "Shegaon", districtId: "buldhana" },
        { id: "sindkhed_raja", name: "Sindkhed Raja", districtId: "buldhana" }
      ]
    },
    {
      id: "chandrapur",
      name: "Chandrapur",
      talukas: [
        { id: "chandrapur_city", name: "Chandrapur", districtId: "chandrapur" },
        { id: "ballarpur", name: "Ballarpur", districtId: "chandrapur" },
        { id: "bhadravati", name: "Bhadravati", districtId: "chandrapur" },
        { id: "bramhapuri", name: "Bramhapuri", districtId: "chandrapur" },
        { id: "chimur", name: "Chimur", districtId: "chandrapur" },
        { id: "corporal", name: "Corporal", districtId: "chandrapur" },
        { id: "gadchiroli", name: "Gadchiroli", districtId: "chandrapur" },
        { id: "gondpipri", name: "Gondpipri", districtId: "chandrapur" },
        { id: "jiwati", name: "Jiwati", districtId: "chandrapur" },
        { id: "mul", name: "Mul", districtId: "chandrapur" },
        { id: "nagbhir", name: "Nagbhir", districtId: "chandrapur" },
        { id: "pombhurna", name: "Pombhurna", districtId: "chandrapur" },
        { id: "rajura", name: "Rajura", districtId: "chandrapur" },
        { id: "saoli", name: "Saoli", districtId: "chandrapur" },
        { id: "sindewahi", name: "Sindewahi", districtId: "chandrapur" },
        { id: "warora", name: "Warora", districtId: "chandrapur" }
      ]
    },
    {
      id: "dhule",
      name: "Dhule",
      talukas: [
        { id: "dhule_city", name: "Dhule", districtId: "dhule" },
        { id: "sakri", name: "Sakri", districtId: "dhule" },
        { id: "shirpur", name: "Shirpur", districtId: "dhule" },
        { id: "sindkhede", name: "Sindkhede", districtId: "dhule" }
      ]
    },
    {
      id: "gadchiroli",
      name: "Gadchiroli",
      talukas: [
        { id: "gadchiroli_city", name: "Gadchiroli", districtId: "gadchiroli" },
        { id: "aheri", name: "Aheri", districtId: "gadchiroli" },
        { id: "armori", name: "Armori", districtId: "gadchiroli" },
        { id: "bhamragad", name: "Bhamragad", districtId: "gadchiroli" },
        { id: "chamorshi", name: "Chamorshi", districtId: "gadchiroli" },
        { id: "desaiganj", name: "Desaiganj", districtId: "gadchiroli" },
        { id: "dhanora", name: "Dhanora", districtId: "gadchiroli" },
        { id: "etapalli", name: "Etapalli", districtId: "gadchiroli" },
        { id: "korchi", name: "Korchi", districtId: "gadchiroli" },
        { id: "kurkheda", name: "Kurkheda", districtId: "gadchiroli" },
        { id: "mulchera", name: "Mulchera", districtId: "gadchiroli" },
        { id: "sironcha", name: "Sironcha", districtId: "gadchiroli" }
      ]
    },
    {
      id: "gondia",
      name: "Gondia",
      talukas: [
        { id: "gondia_city", name: "Gondia", districtId: "gondia" },
        { id: "amgaon", name: "Amgaon", districtId: "gondia" },
        { id: "arjuni_morgaon", name: "Arjuni Morgaon", districtId: "gondia" },
        { id: "deori", name: "Deori", districtId: "gondia" },
        { id: "goregaon", name: "Goregaon", districtId: "gondia" },
        { id: "sadak_arjuni", name: "Sadak Arjuni", districtId: "gondia" },
        { id: "salekasa", name: "Salekasa", districtId: "gondia" },
        { id: "tirora", name: "Tirora", districtId: "gondia" }
      ]
    },
    {
      id: "hingoli",
      name: "Hingoli",
      talukas: [
        { id: "hingoli_city", name: "Hingoli", districtId: "hingoli" },
        { id: "aundha", name: "Aundha", districtId: "hingoli" },
        { id: "basmath", name: "Basmath", districtId: "hingoli" },
        { id: "kalamnuri", name: "Kalamnuri", districtId: "hingoli" },
        { id: "sengaon", name: "Sengaon", districtId: "hingoli" }
      ]
    },
    {
      id: "jalgaon",
      name: "Jalgaon",
      talukas: [
        { id: "jalgaon_city", name: "Jalgaon", districtId: "jalgaon" },
        { id: "amalner", name: "Amalner", districtId: "jalgaon" },
        { id: "bhusawal", name: "Bhusawal", districtId: "jalgaon" },
        { id: "bodvad", name: "Bodvad", districtId: "jalgaon" },
        { id: "chopda", name: "Chopda", districtId: "jalgaon" },
        { id: "dharangaon", name: "Dharangaon", districtId: "jalgaon" },
        { id: "erandol", name: "Erandol", districtId: "jalgaon" },
        { id: "jamner", name: "Jamner", districtId: "jalgaon" },
        { id: "muktainagar", name: "Muktainagar", districtId: "jalgaon" },
        { id: "pachora", name: "Pachora", districtId: "jalgaon" },
        { id: "parola", name: "Parola", districtId: "jalgaon" },
        { id: "raver", name: "Raver", districtId: "jalgaon" },
        { id: "yawal", name: "Yawal", districtId: "jalgaon" }
      ]
    },
    {
      id: "jalna",
      name: "Jalna",
      talukas: [
        { id: "jalna_city", name: "Jalna", districtId: "jalna" },
        { id: "ambad", name: "Ambad", districtId: "jalna" },
        { id: "badnapur", name: "Badnapur", districtId: "jalna" },
        { id: "bhokardan", name: "Bhokardan", districtId: "jalna" },
        { id: "ghansawangi", name: "Ghansawangi", districtId: "jalna" },
        { id: "jafrabad", name: "Jafrabad", districtId: "jalna" },
        { id: "mantha", name: "Mantha", districtId: "jalna" },
        { id: "partur", name: "Partur", districtId: "jalna" }
      ]
    },
    {
      id: "kolhapur",
      name: "Kolhapur",
      talukas: [
        { id: "kolhapur_city", name: "Kolhapur", districtId: "kolhapur" },
        { id: "ajra", name: "Ajra", districtId: "kolhapur" },
        { id: "bhudargad", name: "Bhudargad", districtId: "kolhapur" },
        { id: "chandgad", name: "Chandgad", districtId: "kolhapur" },
        { id: "gadhinglaj", name: "Gadhinglaj", districtId: "kolhapur" },
        { id: "hatkanangle", name: "Hatkanangle", districtId: "kolhapur" },
        { id: "kagal", name: "Kagal", districtId: "kolhapur" },
        { id: "karvir", name: "Karvir", districtId: "kolhapur" },
        { id: "panhala", name: "Panhala", districtId: "kolhapur" },
        { id: "radhanagari", name: "Radhanagari", districtId: "kolhapur" },
        { id: "shahuwadi", name: "Shahuwadi", districtId: "kolhapur" },
        { id: "shirol", name: "Shirol", districtId: "kolhapur" }
      ]
    },
    {
      id: "latur",
      name: "Latur",
      talukas: [
        { id: "latur_city", name: "Latur", districtId: "latur" },
        { id: "ahmedpur", name: "Ahmedpur", districtId: "latur" },
        { id: "ausa", name: "Ausa", districtId: "latur" },
        { id: "chakur", name: "Chakur", districtId: "latur" },
        { id: "deoni", name: "Deoni", districtId: "latur" },
        { id: "jalkot", name: "Jalkot", districtId: "latur" },
        { id: "nilanga", name: "Nilanga", districtId: "latur" },
        { id: "renapur", name: "Renapur", districtId: "latur" },
        { id: "shirur_anantpal", name: "Shirur Anantpal", districtId: "latur" },
        { id: "udgir", name: "Udgir", districtId: "latur" }
      ]
    },
    {
      id: "mumbai_city",
      name: "Mumbai City",
      talukas: [
        { id: "mumbai_city_island", name: "Mumbai City (Island)", districtId: "mumbai_city" }
      ]
    },
    {
      id: "mumbai_suburban",
      name: "Mumbai Suburban",
      talukas: [
        { id: "andheri", name: "Andheri", districtId: "mumbai_suburban" },
        { id: "borivali", name: "Borivali", districtId: "mumbai_suburban" },
        { id: "kurla", name: "Kurla", districtId: "mumbai_suburban" }
      ]
    },
    {
      id: "nagpur",
      name: "Nagpur",
      talukas: [
        { id: "nagpur_city", name: "Nagpur", districtId: "nagpur" },
        { id: "bhiwapur", name: "Bhiwapur", districtId: "nagpur" },
        { id: "hingna", name: "Hingna", districtId: "nagpur" },
        { id: "kamptee", name: "Kamptee", districtId: "nagpur" },
        { id: "katol", name: "Katol", districtId: "nagpur" },
        { id: "kuhi", name: "Kuhi", districtId: "nagpur" },
        { id: "mauda", name: "Mauda", districtId: "nagpur" },
        { id: "narkhed", name: "Narkhed", districtId: "nagpur" },
        { id: "parseoni", name: "Parseoni", districtId: "nagpur" },
        { id: "ramtek", name: "Ramtek", districtId: "nagpur" },
        { id: "saoner", name: "Saoner", districtId: "nagpur" },
        { id: "umred", name: "Umred", districtId: "nagpur" }
      ]
    },
    {
      id: "nanded",
      name: "Nanded",
      talukas: [
        { id: "nanded_city", name: "Nanded", districtId: "nanded" },
        { id: "ardhapur", name: "Ardhapur", districtId: "nanded" },
        { id: "bhokar", name: "Bhokar", districtId: "nanded" },
        { id: "biloli", name: "Biloli", districtId: "nanded" },
        { id: "degloor", name: "Degloor", districtId: "nanded" },
        { id: "dharmabad", name: "Dharmabad", districtId: "nanded" },
        { id: "hadgaon", name: "Hadgaon", districtId: "nanded" },
        { id: "himayatnagar", name: "Himayatnagar", districtId: "nanded" },
        { id: "kandhar", name: "Kandhar", districtId: "nanded" },
        { id: "kinwat", name: "Kinwat", districtId: "nanded" },
        { id: "loha", name: "Loha", districtId: "nanded" },
        { id: "mahoor", name: "Mahoor", districtId: "nanded" },
        { id: "mukhed", name: "Mukhed", districtId: "nanded" },
        { id: "naigaon", name: "Naigaon", districtId: "nanded" },
        { id: "umri", name: "Umri", districtId: "nanded" }
      ]
    },
    {
      id: "nandurbar",
      name: "Nandurbar",
      talukas: [
        { id: "nandurbar_city", name: "Nandurbar", districtId: "nandurbar" },
        { id: "akkalkuwa", name: "Akkalkuwa", districtId: "nandurbar" },
        { id: "dhadgaon", name: "Dhadgaon", districtId: "nandurbar" },
        { id: "nawapur", name: "Nawapur", districtId: "nandurbar" },
        { id: "shahada", name: "Shahada", districtId: "nandurbar" },
        { id: "taloda", name: "Taloda", districtId: "nandurbar" }
      ]
    },
    {
      id: "nashik",
      name: "Nashik",
      talukas: [
        { id: "nashik_city", name: "Nashik", districtId: "nashik" },
        { id: "baglan", name: "Baglan", districtId: "nashik" },
        { id: "chandvad", name: "Chandvad", districtId: "nashik" },
        { id: "deola", name: "Deola", districtId: "nashik" },
        { id: "dindori", name: "Dindori", districtId: "nashik" },
        { id: "igatpuri", name: "Igatpuri", districtId: "nashik" },
        { id: "kalwan", name: "Kalwan", districtId: "nashik" },
        { id: "malegaon", name: "Malegaon", districtId: "nashik" },
        { id: "nandgaon", name: "Nandgaon", districtId: "nashik" },
        { id: "niphad", name: "Niphad", districtId: "nashik" },
        { id: "peint", name: "Peint", districtId: "nashik" },
        { id: "sinnar", name: "Sinnar", districtId: "nashik" },
        { id: "surgana", name: "Surgana", districtId: "nashik" },
        { id: "trimbak", name: "Trimbak", districtId: "nashik" },
        { id: "yeola", name: "Yeola", districtId: "nashik" }
      ]
    },
    {
      id: "osmanabad",
      name: "Osmanabad",
      talukas: [
        { id: "osmanabad_city", name: "Osmanabad", districtId: "osmanabad" },
        { id: "bhoom", name: "Bhoom", districtId: "osmanabad" },
        { id: "kalamb", name: "Kalamb", districtId: "osmanabad" },
        { id: "lohara", name: "Lohara", districtId: "osmanabad" },
        { id: "omerga", name: "Omerga", districtId: "osmanabad" },
        { id: "paranda", name: "Paranda", districtId: "osmanabad" },
        { id: "tuljapur", name: "Tuljapur", districtId: "osmanabad" },
        { id: "washi", name: "Washi", districtId: "osmanabad" }
      ]
    },
    {
      id: "palghar",
      name: "Palghar",
      talukas: [
        { id: "palghar_city", name: "Palghar", districtId: "palghar" },
        { id: "dahanu", name: "Dahanu", districtId: "palghar" },
        { id: "jawhar", name: "Jawhar", districtId: "palghar" },
        { id: "mokhada", name: "Mokhada", districtId: "palghar" },
        { id: "talasari", name: "Talasari", districtId: "palghar" },
        { id: "vasai", name: "Vasai", districtId: "palghar" },
        { id: "vikramgad", name: "Vikramgad", districtId: "palghar" },
        { id: "wada", name: "Wada", districtId: "palghar" }
      ]
    },
    {
      id: "parbhani",
      name: "Parbhani",
      talukas: [
        { id: "parbhani_city", name: "Parbhani", districtId: "parbhani" },
        { id: "gangakhed", name: "Gangakhed", districtId: "parbhani" },
        { id: "jintur", name: "Jintur", districtId: "parbhani" },
        { id: "manwath", name: "Manwath", districtId: "parbhani" },
        { id: "pathri", name: "Pathri", districtId: "parbhani" },
        { id: "palam", name: "Palam", districtId: "parbhani" },
        { id: "purna", name: "Purna", districtId: "parbhani" },
        { id: "sailu", name: "Sailu", districtId: "parbhani" },
        { id: "sonpeth", name: "Sonpeth", districtId: "parbhani" }
      ]
    },
    {
      id: "pune",
      name: "Pune",
      talukas: [
        { id: "pune_city", name: "Pune City", districtId: "pune" },
        { id: "ambegaon", name: "Ambegaon", districtId: "pune" },
        { id: "baramati", name: "Baramati", districtId: "pune" },
        { id: "bhor", name: "Bhor", districtId: "pune" },
        { id: "daund", name: "Daund", districtId: "pune" },
        { id: "haveli", name: "Haveli", districtId: "pune" },
        { id: "indapur", name: "Indapur", districtId: "pune" },
        { id: "junnar", name: "Junnar", districtId: "pune" },
        { id: "khed", name: "Khed", districtId: "pune" },
        { id: "malegaon_pune", name: "Malegaon", districtId: "pune" },
        { id: "mulshi", name: "Mulshi", districtId: "pune" },
        { id: "pimpri_chinchwad", name: "Pimpri Chinchwad", districtId: "pune" },
        { id: "purandar", name: "Purandar", districtId: "pune" },
        { id: "shirur", name: "Shirur", districtId: "pune" },
        { id: "velhe", name: "Velhe", districtId: "pune" }
      ]
    },
    {
      id: "raigad",
      name: "Raigad",
      talukas: [
        { id: "alibag", name: "Alibag", districtId: "raigad" },
        { id: "karjat_raigad", name: "Karjat", districtId: "raigad" },
        { id: "khalapur", name: "Khalapur", districtId: "raigad" },
        { id: "mahad", name: "Mahad", districtId: "raigad" },
        { id: "mangaon", name: "Mangaon", districtId: "raigad" },
        { id: "mhasla", name: "Mhasla", districtId: "raigad" },
        { id: "murud", name: "Murud", districtId: "raigad" },
        { id: "panvel", name: "Panvel", districtId: "raigad" },
        { id: "pen", name: "Pen", districtId: "raigad" },
        { id: "poladpur", name: "Poladpur", districtId: "raigad" },
        { id: "roha", name: "Roha", districtId: "raigad" },
        { id: "shrivardhan", name: "Shrivardhan", districtId: "raigad" },
        { id: "sudhagad", name: "Sudhagad", districtId: "raigad" },
        { id: "tala", name: "Tala", districtId: "raigad" },
        { id: "uran", name: "Uran", districtId: "raigad" }
      ]
    },
    {
      id: "ratnagiri",
      name: "Ratnagiri",
      talukas: [
        { id: "ratnagiri_city", name: "Ratnagiri", districtId: "ratnagiri" },
        { id: "chiplun", name: "Chiplun", districtId: "ratnagiri" },
        { id: "dapoli", name: "Dapoli", districtId: "ratnagiri" },
        { id: "guhagar", name: "Guhagar", districtId: "ratnagiri" },
        { id: "khed_ratnagiri", name: "Khed", districtId: "ratnagiri" },
        { id: "lanja", name: "Lanja", districtId: "ratnagiri" },
        { id: "mandangad", name: "Mandangad", districtId: "ratnagiri" },
        { id: "rajapur", name: "Rajapur", districtId: "ratnagiri" },
        { id: "sangameshwar", name: "Sangameshwar", districtId: "ratnagiri" }
      ]
    },
    {
      id: "sangli",
      name: "Sangli",
      talukas: [
        { id: "sangli_city", name: "Sangli", districtId: "sangli" },
        { id: "atpadi", name: "Atpadi", districtId: "sangli" },
        { id: "jat", name: "Jat", districtId: "sangli" },
        { id: "kadegaon", name: "Kadegaon", districtId: "sangli" },
        { id: "kavathe_mahankal", name: "Kavathe Mahankal", districtId: "sangli" },
        { id: "khanapur", name: "Khanapur", districtId: "sangli" },
        { id: "miraj", name: "Miraj", districtId: "sangli" },
        { id: "palus", name: "Palus", districtId: "sangli" },
        { id: "shirala", name: "Shirala", districtId: "sangli" },
        { id: "tasgaon", name: "Tasgaon", districtId: "sangli" },
        { id: "walwa", name: "Walwa", districtId: "sangli" }
      ]
    },
    {
      id: "satara",
      name: "Satara",
      talukas: [
        { id: "satara_city", name: "Satara", districtId: "satara" },
        { id: "jaoli", name: "Jaoli", districtId: "satara" },
        { id: "khandala", name: "Khandala", districtId: "satara" },
        { id: "khatav", name: "Khatav", districtId: "satara" },
        { id: "koregaon", name: "Koregaon", districtId: "satara" },
        { id: "man", name: "Man", districtId: "satara" },
        { id: "mahabaleshwar", name: "Mahabaleshwar", districtId: "satara" },
        { id: "patan", name: "Patan", districtId: "satara" },
        { id: "phaltan", name: "Phaltan", districtId: "satara" },
        { id: "wai", name: "Wai", districtId: "satara" },
        { id: "karad", name: "Karad", districtId: "satara" }
      ]
    },
    {
      id: "sindhudurg",
      name: "Sindhudurg",
      talukas: [
        { id: "kudal", name: "Kudal", districtId: "sindhudurg" },
        { id: "malvan", name: "Malvan", districtId: "sindhudurg" },
        { id: "devgad", name: "Devgad", districtId: "sindhudurg" },
        { id: "sawantwadi", name: "Sawantwadi", districtId: "sindhudurg" },
        { id: "vengurla", name: "Vengurla", districtId: "sindhudurg" },
        { id: "dodamarg", name: "Dodamarg", districtId: "sindhudurg" },
        { id: "kankavli", name: "Kankavli", districtId: "sindhudurg" },
        { id: "vaibhavwadi", name: "Vaibhavwadi", districtId: "sindhudurg" }
      ]
    },
    {
      id: "solapur",
      name: "Solapur",
      talukas: [
        { id: "solapur_city", name: "Solapur", districtId: "solapur" },
        { id: "akkalkot", name: "Akkalkot", districtId: "solapur" },
        { id: "barshi", name: "Barshi", districtId: "solapur" },
        { id: "karmala", name: "Karmala", districtId: "solapur" },
        { id: "madha", name: "Madha", districtId: "solapur" },
        { id: "malshiras", name: "Malshiras", districtId: "solapur" },
        { id: "mangalvedhe", name: "Mangalvedhe", districtId: "solapur" },
        { id: "mohol", name: "Mohol", districtId: "solapur" },
        { id: "north_solapur", name: "North Solapur", districtId: "solapur" },
        { id: "pandharpur", name: "Pandharpur", districtId: "solapur" },
        { id: "sangole", name: "Sangole", districtId: "solapur" },
        { id: "south_solapur", name: "South Solapur", districtId: "solapur" }
      ]
    },
    {
      id: "thane",
      name: "Thane",
      talukas: [
        { id: "thane_city", name: "Thane", districtId: "thane" },
        { id: "ambarnath", name: "Ambarnath", districtId: "thane" },
        { id: "bhiwandi", name: "Bhiwandi", districtId: "thane" },
        { id: "kalyan", name: "Kalyan", districtId: "thane" },
        { id: "murbad", name: "Murbad", districtId: "thane" },
        { id: "shahapur", name: "Shahapur", districtId: "thane" },
        { id: "ulhasnagar", name: "Ulhasnagar", districtId: "thane" }
      ]
    },
    {
      id: "wardha",
      name: "Wardha",
      talukas: [
        { id: "wardha_city", name: "Wardha", districtId: "wardha" },
        { id: "arvi", name: "Arvi", districtId: "wardha" },
        { id: "ashti_wardha", name: "Ashti", districtId: "wardha" },
        { id: "deoli", name: "Deoli", districtId: "wardha" },
        { id: "hinganghat", name: "Hinganghat", districtId: "wardha" },
        { id: "karanja", name: "Karanja", districtId: "wardha" },
        { id: "samudrapur", name: "Samudrapur", districtId: "wardha" },
        { id: "seloo", name: "Seloo", districtId: "wardha" }
      ]
    },
    {
      id: "washim",
      name: "Washim",
      talukas: [
        { id: "washim_city", name: "Washim", districtId: "washim" },
        { id: "karanja_lad", name: "Karanja Lad", districtId: "washim" },
        { id: "malegaon_washim", name: "Malegaon", districtId: "washim" },
        { id: "mangrulpir", name: "Mangrulpir", districtId: "washim" },
        { id: "manora", name: "Manora", districtId: "washim" },
        { id: "risod", name: "Risod", districtId: "washim" }
      ]
    },
    {
      id: "yavatmal",
      name: "Yavatmal",
      talukas: [
        { id: "yavatmal_city", name: "Yavatmal", districtId: "yavatmal" },
        { id: "arni", name: "Arni", districtId: "yavatmal" },
        { id: "babulgaon", name: "Babulgaon", districtId: "yavatmal" },
        { id: "darwha", name: "Darwha", districtId: "yavatmal" },
        { id: "digras", name: "Digras", districtId: "yavatmal" },
        { id: "ghatanji", name: "Ghatanji", districtId: "yavatmal" },
        { id: "kalamb_yavatmal", name: "Kalamb", districtId: "yavatmal" },
        { id: "kelapur", name: "Kelapur", districtId: "yavatmal" },
        { id: "mahagaon", name: "Mahagaon", districtId: "yavatmal" },
        { id: "ner", name: "Ner", districtId: "yavatmal" },
        { id: "pusad", name: "Pusad", districtId: "yavatmal" },
        { id: "ralegaon", name: "Ralegaon", districtId: "yavatmal" },
        { id: "umarkhed", name: "Umarkhed", districtId: "yavatmal" },
        { id: "wani", name: "Wani", districtId: "yavatmal" },
        { id: "zari_jamani", name: "Zari Jamani", districtId: "yavatmal" }
      ]
    }
  ];
  
  class MaharashtraApiService {
    private districts: District[] = [];
    private isLoaded: boolean = false;
  
    constructor() {
      this.loadData();
    }
  
    private async loadData(): Promise<void> {
      try {
        // Try to fetch from external API first
        // Note: You can replace this with any reliable API endpoint
        // For now, using static data as fallback
        this.districts = MAHARASHTRA_DISTRICTS;
        this.isLoaded = true;
      } catch (error) {
        console.warn('Failed to load from external API, using fallback data:', error);
        this.districts = MAHARASHTRA_DISTRICTS;
        this.isLoaded = true;
      }
    }
  
    async getDistricts(): Promise<District[]> {
      if (!this.isLoaded) {
        await this.loadData();
      }
      return this.districts.map(d => ({ ...d, talukas: [] })); // Return districts without talukas for dropdown
    }
  
    async getTalukasByDistrict(districtId: string): Promise<Taluka[]> {
      if (!this.isLoaded) {
        await this.loadData();
      }
      const district = this.districts.find(d => d.id === districtId);
      return district?.talukas || [];
    }
  
    async getAllDistricts(): Promise<District[]> {
      if (!this.isLoaded) {
        await this.loadData();
      }
      return this.districts;
    }
  }
  
  export const maharashtraApiService = new MaharashtraApiService();
  