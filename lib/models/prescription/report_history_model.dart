class ReportHistoryModel{
  String? udCreateBy;
  String? feedbackSendBy;
  int? morningCount;
  int? eveningCount;
  String? district;
  int selectedFlag = 0; //1= MS code selected, 2= Morning, 3 = Evening
  int totalRx = 0;
  int totalView = 0;

  ReportHistoryModel({this.udCreateBy,this.morningCount,this.eveningCount});
}