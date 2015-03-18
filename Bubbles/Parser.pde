//This file parses the CSV data sheet in a specific format


String[][] table;
String[][] categorytable;
String[] categories;

int[] countrycount;

ArrayList<int> importantYears;
int[] importantyears;

class year_node{
    int year_count;
    boolean US_flag;
}

class Right{
    String right_name;
    year_node[] count;
    String description;
    int category;
    int USintroduced;
    String introduce;
    int introduced;//false if String introduce is empty
}

Right[] rightarray;
int start = 19;
int start_year = 1789;
int end_year = 2012;

String[] splitLine(String line){
    int substringcount = 0;
    ArrayList<String> stringlist = new ArrayList<String>();
    for(int i=0; i<line.length()-1; i++){
    //    if((line.charAt(i) == ',') && (line.charAt(i+1) != ' ')){
        if((line.substring(i, i+1).equals(",")) && !(line.substring(i+1, i+2).equals(" "))){
            stringlist.add(line.substring(substringcount, i));
            substringcount = i+1;
        }
    }
    String[] strings = new String[stringlist.size()];
    strings = stringlist.toArray(strings);
    return strings;
}

void parse() {
  
  String[] lines;
  
    //parsing -- updated for mobile
if(onMobile){
    lines = loadStrings("../data/rights_mobile.csv");
    start_year = 2012;
}else{
    lines = loadStrings("../data/dj_rights_060214.csv");
}

    countrycount = new int[(end_year-start_year)+1];
    importantYears = new ArrayList<int>();

    table = new String[lines.length][];

    for(int i=0; i<lines.length; i++){
        table[i] = splitLine(lines[i]);
    }
    
    //lines = loadStrings("../data/us_categorization_061814.csv");
    lines = loadStrings("../data/substantive_categorization_060214.csv");
    //lines = loadStrings("../data/substantive_categorization_021514.csv");
    
    categories = split(lines[0], ',');
    categorytable = new String[lines.length-1][];
    
    for(int i=1; i<lines.length; i++){
        lines[i] = lines[i].replace("\"", "");
        categorytable[i-1] = split(lines[i], ',');
    }  
     
    rightarray = new Right[table[0].length-start];
     
    for(int i=0; i<(table[0].length-start); i++){
        rightarray[i] = new Right();
        rightarray[i].right_name = table[0][i+start];
        rightarray[i].count = new year_node[(end_year-start_year) + 1];
        rightarray[i].description = table[1][i+start];
        rightarray[i].description = rightarray[i].description.replace("\"", "");
        
        for(int j=0; j<categories.length; j++){
            for(int k=0; k<lines.length-1; k++){
                if(rightarray[i].right_name.equals(categorytable[k][j]/*.substring(0, categorytable[k][j].indexOf(':') - 1)*/)){
                    rightarray[i].category = j+1;
                }
            }
        }
        
        for(int j=0; j<=(end_year-start_year); j++){
            rightarray[i].count[j] = new year_node();
            rightarray[i].count[j].US_flag = false;
            
            for(int k=2; k<table.length; k++){
                
                //if same year
                if(int(table[k][3]) == j+start_year){
                    if(i==0)  countrycount[j]++;
                  
                    //if right is "1. yes" then increase count for year
                    if((table[k][i+start].equals("1. yes")) || (table[k][i+start].equals("2. full")) || (table[k][i+start].equals("1. conditional")) ){
                        if(rightarray[i].introduced == 0){
                            rightarray[i].introduce = table[k][2];
                            rightarray[i].introduced = j+start_year;
                        }
                        rightarray[i].count[j].year_count++;
                        
                        //if US is a yes
                        if(table[k][4].equals("USA")){
                            rightarray[i].count[j].US_flag = true;
                            if(rightarray[i].USintroduced == 0){
                                rightarray[i].USintroduced = j+start_year;
//                                if(!importantYears.contains(j+start_year)){
//                                    importantYears.add(j+start_year);
//                                }
                            }
                        }
                    }
                }
                
                //skip till next country if k year is more than j year
                if(int(table[k][3]) >= (j+start_year)){
                    k += (2012-int(table[k][3]));
                }
                else{
                    k += ((j+start_year) - int(table[k][3])) - 1;
                }
            }
        }
    }
    for(int i = start_year; i <= end_year; i += 40){
        importantYears.add(i);
    }
    if(!importantYears.contains(end_year)){
        importantYears.add(end_year);
    }
    importantyears = new int[importantYears.size()];
    importantyears = importantYears.toArray(importantyears);
    importantyears = sort(importantyears);

//  int year = 2012;
//  println(rightarray[13].right_name);
//  println(rightarray[13].count[year-start_year].year_count);
//  println(rightarray[13].count[year-start_year].US_flag);
}
