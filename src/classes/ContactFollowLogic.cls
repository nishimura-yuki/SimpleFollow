public with sharing class ContactFollowLogic {

	public List<EmailTemplate> getTemplate(){
		BookmarkMailTemplate__c  setting = BookmarkMailTemplate__c.getInstance(UserInfo.getUserId());
		if(setting == null){
			return new List<EmailTemplate>();
		}
		List<Id> Ids = new List<String>();
		Integer i = 1;
		while(true){
			Object tmp;
			try{
				tmp = setting.get('template' + i + '__c');
			}catch(SObjectException e){
				break;
			}
			if(tmp == null){
				break;
			}
			Ids.add(String.ValueOf(tmp));
			i++;
		}
		
		if(Ids.size() <= 0){
			return new List<EmailTemplate>();  
		}
		List<EmailTemplate> tempList = [select Id , Name from EmailTemplate where Id in :Ids and isActive = true];
		Map<Id , EmailTemplate> tempMap = new Map<Id,EmailTemplate>();
		for(EmailTemplate e : tempList){
			tempMap.put(e.Id , e);
		}

		List<EmailTemplate> resultList = new  List<EmailTemplate>();
		for(Id tempId : Ids){
			resultList.add(tempMap.get(tempId));
		}
		return resultList;
	}

	public Boolean reserveMail(List<String> contactIds , String templateId){

		//スケジュールで予約
		BookmarkMailTemplate__c  setting = BookmarkMailTemplate__c.getInstance(UserInfo.getUserId());
		String sendtimeStr = setting.sendtime__c;
		String[] params = sendtimeStr.split(':');
		DateTime nowDateTime = DateTime.now();
		DateTime sendDatetime = DateTime.newInstance(nowDateTime.date() , 
													Time.newInstance(Integer.ValueOf(params[0]),
													Integer.ValueOf(params[1]),0,0));
		if(nowDateTime > sendDatetime){
			sendDatetime = sendDateTime.addDays(1);
		}
		FollowMailScheduler.submitSchedule(contactIds , templateId , sendDateTime);
		return true;
	}
	
	public Boolean sendMail(List<String> contactIds , String templateId){
		
		//MassEmailMessage の機能でメール送信
		Messaging.MassEmailMessage message = new Messaging.MassEmailMessage();
		message.setTargetObjectIds(contactIds);
		message.setTemplateId(templateId);
		Messaging.sendEmail(new Messaging.MassEmailMessage[] {message });
		
		return true;
		
	}

}