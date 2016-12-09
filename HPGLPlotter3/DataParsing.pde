String getDateStringReverse(Date date) { 

  String year = ""+(date.getYear()+1900); 
  String month = ""+(date.getMonth()+1); 
  String day = ""+date.getDate();
  while (month.length ()<2) month = '0'+month;  
  while (day.length ()<2) day = '0'+day;  
  return(year+"-"+month+"-"+day);
}
String getDateString(Date date) { 

  String year = ""+(date.getYear()+1900); 
  String month = ""+(date.getMonth()+1); 
  String day = ""+date.getDate();
  while (month.length ()<2) month = '0'+month;  
  while (day.length ()<2) day = '0'+day;  
  return(day+"/"+month+"/"+year);
}
String getDateAndTimeString(long startMils, long endMils) { 
  Date date = new Date(startMils); 
  String year = ""+(date.getYear()+1900); 
  String month = ""+(date.getMonth()+1); 
  String day = ""+date.getDate();
  while (month.length ()<2) month = '0'+month;  
  while (day.length ()<2) day = '0'+day;  
  
  Date startDate = date; 
  
  String startHours = ""+date.getHours(); 
  String startMins = ""+date.getMinutes(); 
  while (startHours.length ()<2) startHours = '0'+startHours;  
  while (startMins.length ()<2) startMins = '0'+startMins;  
  date.setTime(endMils); 
  String endHours = ""+date.getHours(); 
  if(date.getHours() == 0) endHours = "24"; 
  
  // pretty nasty hack to know if we have gone over 24 hours
  //println("END HOURS " +endHours+" "+(endHours=="0")); 
  String endMins = ""+date.getMinutes(); 
  while (endHours.length ()<2) endHours = '0'+endHours;  
  while (endMins.length ()<2) endMins = '0'+endMins;  


  //println(day+"/"+month+"/"+year+" "+startHours+":"+startMins+" - "+endHours+":"+endMins); 
  return(day+"/"+month+"/"+year+" "+startHours+":"+startMins+"-"+endHours+":"+endMins);
}


String getHourAndMinuteString(long mils) { 
  Date date = new Date(mils); 
  String hours = ""+date.getHours(); 
  String mins = ""+date.getMinutes(); 
  while (hours.length ()<2) hours = '0'+hours;  
  while (mins.length ()<2) mins = '0'+mins;  
  return (hours+mins);
}

Date convertFilenameToDate(String fileName) { 
    // strip extension
   fileName = fileName.substring(0, fileName.length()-5); 
  String[] datecomponents = split(fileName, "-"); 
  println("converting "+datecomponents[1]+'/'+datecomponents[2]+'/'+datecomponents[0]+" to date : "); 
  Date time = new Date(datecomponents[1]+'/'+datecomponents[2]+'/'+datecomponents[0]); 
  //println(time);
  return time; 
  
}