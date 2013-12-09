@isTest
private class ContactFollowLogicTest {

	public static testMethod  void test_getTemplate(){
		
		List<EmailTemplate> templates = new List<EmailTemplate>();
		templates = [Select Id , Name from EmailTemplate where FolderId = :UserInfo.getOrganizationId() limit 3];

		/*
		EmailTemplate template1 = new EmailTemplate();
		template1.Name = 'テストテンプレ1';
		template1.DeveloperName = 'test_template_1';
		template1.FolderId = UserInfo.getOrganizationId();
		template1.TemplateType = 'text';
		EmailTemplate template2 = new EmailTemplate();
		template2.Name = 'テストテンプレ2';
		template2.DeveloperName = 'test_template_2';
		template2.FolderId = UserInfo.getOrganizationId();
		template2.TemplateType = 'text';
		EmailTemplate template3 = new EmailTemplate();
		template3.Name = 'テストテンプレ3';
		template3.DeveloperName = 'test_template_3';
		template3.FolderId = UserInfo.getOrganizationId();
		template3.TemplateType = 'text';

		templates.add(template1);
		templates.add(template2);
		templates.add(template3);

		insert templates;*/

		BookmarkMailTemplate__c setting = new BookmarkMailTemplate__c();
		setting.sendtime__c = '18:00';
		setting.template1__c = '';
		setting.template2__c = '';
		setting.template3__c = '';

		insert setting;

		Test.startTest();
		
		ContactFollowLogic logic = new ContactFollowLogic();

		List<EmailTemplate> tempResult;
		if(templates.size() > 0){

			setting.template1__c = templates.get(0).Id;
			if(templates.size() >= 2){
				setting.template2__c = templates.get(1).Id;
				if(templates.size() >= 3){
					setting.template3__c = templates.get(2).Id;
				}
			}
			update setting;

			tempResult = logic.getTemplate();
			System.assertEquals(templates.size() , tempResult.size() );
			System.assertEquals(templates.get(0).Name , tempResult.get(0).Name );
			if(templates.size() >= 2){
				System.assertEquals(templates.get(1).Name, tempResult.get(1).Name );
				if(templates.size() >= 3){
					System.assertEquals(templates.get(2).Name , tempResult.get(2).Name );
				}
			}
		}

		//テンプレートが指定されていない場合
		setting.template1__c = null;
		setting.template2__c = null;
		setting.template3__c = null;
		update setting;

		tempResult = logic.getTemplate();
		System.assertEquals(0 , tempResult.size());

		//カスタム設定がない場合
		delete setting;

		tempResult = logic.getTemplate();
		System.assertEquals(0 , tempResult.size());

		Test.stopTest();

	}

	public static testMethod  void test_sendMail(){

		BookmarkMailTemplate__c setting = new BookmarkMailTemplate__c();
		setting.sendtime__c = '00:00';
		insert setting;

		List<EmailTemplate> templates = new List<EmailTemplate>();
		templates = [Select Id from EmailTemplate where FolderId = :UserInfo.getOrganizationId() limit 1];

		List<Contact> contacts = new List<Contact>();
		Contact c1 = new Contact();
		c1.LastName = 'テストの人';
		c1.Email = 'test1@test.com';
		Contact c2 = new Contact();
		c2.LastName = 'test_test';
		c2.Email = 'test2@test.com';
		contacts.add(c1);
		contacts.add(c2);

		insert contacts;

		List<String> ids = new List<String>();
		ids.add(contacts.get(0).Id);
		ids.add(contacts.get(1).Id);

		Test.startTest();

		LIST<AggregateResult> beforeCount;
		LIST<AggregateResult> afterCount;
		ContactFollowLogic logic = new ContactFollowLogic();

		beforeCount = [select count(Id) rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];
		Integer beforeSchedule = Integer.ValueOf(beforeCount.get(0).get('rowCount'));

		system.assert(logic.sendMail( ids , templates.get(0).Id )); 
		system.assertEquals(  1 , Limits.getEmailInvocations() );
		afterCount = [select count(Id)rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];
		system.assertEquals(  beforeSchedule , Integer.ValueOf(afterCount.get(0).get('rowCount')));

		Test.stopTest();
	
	}

	public static testMethod  void test_reserveMail(){

		BookmarkMailTemplate__c setting = new BookmarkMailTemplate__c();
		setting.sendtime__c = '00:00';
		insert setting;

		List<EmailTemplate> templates = new List<EmailTemplate>();
		templates = [Select Id from EmailTemplate where FolderId = :UserInfo.getOrganizationId() limit 1];

		List<Contact> contacts = new List<Contact>();
		Contact c1 = new Contact();
		c1.LastName = 'テストの人';
		c1.Email = 'test1@test.com';
		Contact c2 = new Contact();
		c2.LastName = 'test_test';
		c2.Email = 'test2@test.com';
		contacts.add(c1);
		contacts.add(c2);

		insert contacts;

		List<String> ids = new List<String>();
		ids.add(contacts.get(0).Id);
		ids.add(contacts.get(1).Id);

		Test.startTest();

		LIST<AggregateResult> beforeCount;
		LIST<AggregateResult> afterCount;
		ContactFollowLogic logic = new ContactFollowLogic();

		beforeCount = [select count(Id) rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];
		Integer beforeSchedule = Integer.ValueOf(beforeCount.get(0).get('rowCount'));

		system.assert(logic.reserveMail( ids , templates.get(0).Id )); 
		system.assertEquals(  0 , Limits.getEmailInvocations() );
		afterCount = [select count(Id)rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];
		system.assertEquals(  (beforeSchedule+1) , Integer.ValueOf(afterCount.get(0).get('rowCount')));

		Test.stopTest();
	
	}

}