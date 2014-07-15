//This file parses the CSV data sheet in a specific format

String[] lines;
String[][] table;
String[][] categorytable;
String[] categories;

class year_node{
  int year_count;
  boolean US_flag;
}

class Right{
  String right_name;
  year_node[] count;
  String description;
  int category;
  int introduced;
}

Right[] rightarray;
int start = 19;
int start_year = 1789;
int end_year = 2012;

String[] splitLine(String line){
  int substringcount = 0;
  ArrayList<String> stringlist = new ArrayList<String>();
  println(line.length);
  for(int i=0; i<line.length()-1; i++){
    if((line.charAt(i) == ',') && (line.charAt(i+1) != ' ')){
      stringlist.add(line.substring(substringcount, i));
      substringcount = i+1;
    }
  }
  String[] strings = new String[stringlist.size()];
  strings = stringlist.toArray(strings);
  return strings;
}

void parse() {
  table = new String[18957][];
  lines = loadStrings("../data/dj_rights_060214.csv");
  for(int i=0; i<lines.length; i++){
    if(procjs) table[i] = split(lines[i], ',');
    else table[i] = splitLine(lines[i]);
  }
  
  lines = loadStrings("../data/us_categorization_061814.csv");
  //lines = loadStrings("../substantive_categorization_060214.csv");
  
  categories = split(lines[0], ',');
  categorytable = new String[lines.length-1][];
  
  for(int i=1; i<lines.length; i++){
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
        if(rightarray[i].right_name.equals(categorytable[k][j])){
          rightarray[i].category = j+1;
        }
      }
    }
    
    for(int j=0; j<=(end_year-start_year); j++){
      rightarray[i].count[j] = new year_node();
      rightarray[i].count[j].US_flag = false;
      
      for(int k=2; k<18957; k++){
        
        //if same year
        if(int(table[k][3]) == j+start_year){
          
          //if right is "1. yes" then increase count for year
          if((table[k][i+start].equals("1. yes")) ||
            (table[k][i+start].equals("2. full"))){
              
              rightarray[i].count[j].year_count++;
              
              //if US is a yes
              if(table[k][4].equals("USA")){
                rightarray[i].count[j].US_flag = true;
                if(rightarray[i].introduced == 0)  rightarray[i].introduced = j+start_year;
              }
          }
        }
        
//        print(table[k][3]);
//        print(" : ");
//        print(table[k][4]);
//        print(" : ");
//        println(table[k][i+start]);
        
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
//  int year = 2012;
//  println(rightarray[13].right_name);
//  println(rightarray[13].count[year-start_year].year_count);
//  println(rightarray[13].count[year-start_year].US_flag);
}
