@isTest
private class ContactFollowExtensionControllerTest {

	private static ContactFollowExtensionController setupController(){
		List<Contact> contacts = new List<Contact>();
		Contact c1 = new Contact();
		c1.LastName = 'テストの人';
		c1.Email = 'test1@test.com';
		contacts.add(c1);
		insert contacts;
		
		ApexPages.StandardController stdController = new ApexPages.StandardController(contacts.get(0));
		ContactFollowExtensionController controller = new ContactFollowExtensionController(stdController);
		
		return controller;
		
	}

	public static testMethod  void test_constructer(){
		ContactFollowExtensionController controller = setupController();
		System.assertEquals('テストの人' , controller.recipient.LastName);
	}

	public static testMethod  void test_init(){
		ContactFollowExtensionController controller = setupController();
		
		List<EmailTemplate> templates = new List<EmailTemplate>();
		templates = [Select Id , Name from EmailTemplate where FolderId = :UserInfo.getOrganizationId() and isActive=true limit 3];
		
		BookmarkMailTemplate__c setting = new BookmarkMailTemplate__c();
		setting.sendtime__c = '18:00';
		setting.template1__c = '';
		setting.template2__c = '';
		setting.template3__c = '';
		insert setting;
		
		Test.startTest();
		
		if(templates.size() > 0){
			setting.template1__c = templates.get(0).Id;
			update setting;
			controller.init();
			System.assertEquals(1 , controller.templateSelect.size() );
			System.assertEquals(setting.template1__c , controller.selection );
			setting.template1__c = '';
			update setting;
		}
		
		controller.init();
		System.assertEquals(0 , controller.templateSelect.size() );
		System.assertEquals(null , controller.selection );
		
		Test.stopTest();

	}

	public static testMethod  void test_reservesend(){

		List<EmailTemplate> templates = new List<EmailTemplate>();
		templates = [Select Id , Name from EmailTemplate where FolderId = :UserInfo.getOrganizationId() and isActive=true limit 3];
		if(templates.size() <= 0){
			return;
		}

		LIST<AggregateResult> beforeCount;
		LIST<AggregateResult> afterCount;
		beforeCount = [select count(Id) rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];
		Integer beforeSchedule = Integer.ValueOf(beforeCount.get(0).get('rowCount'));

		BookmarkMailTemplate__c setting = new BookmarkMailTemplate__c();
		setting.sendtime__c = '18:00';
		setting.template1__c = templates.get(0).Id;
		insert setting;

		ContactFollowExtensionController controller = setupController();
		controller.init();
		
		Test.startTest();
		
		system.assertEquals(Page.PublisherContactFollowFinish.getUrl() , controller.reservedsend().getUrl());
		system.assertEquals(  0 , Limits.getEmailInvocations() );
		afterCount = [select count(Id)rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];
		system.assertEquals(  (beforeSchedule+1) , Integer.ValueOf(afterCount.get(0).get('rowCount')));
		
		Test.stopTest();
		
	}

	public static testMethod  void test_directsend(){
		
		List<EmailTemplate> templates = new List<EmailTemplate>();
		templates = [Select Id , Name from EmailTemplate where FolderId = :UserInfo.getOrganizationId() and isActive=true limit 3];
		if(templates.size() <= 0){
			return;
		}
		
		LIST<AggregateResult> beforeCount;
		LIST<AggregateResult> afterCount;
		beforeCount = [select count(Id) rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];
		Integer beforeSchedule = Integer.ValueOf(beforeCount.get(0).get('rowCount'));
		
		BookmarkMailTemplate__c setting = new BookmarkMailTemplate__c();
		setting.sendtime__c = '18:00';
		setting.template1__c = templates.get(0).Id;
		insert setting;

		ContactFollowExtensionController controller = setupController();
		controller.init();
		
		Test.startTest();
		
		system.assertEquals(Page.PublisherContactFollowFinish.getUrl() , controller.directsend().getUrl());
		system.assertEquals( 1 , Limits.getEmailInvocations() );
		afterCount = [select count(Id)rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];
		system.assertEquals(  beforeSchedule , Integer.ValueOf(afterCount.get(0).get('rowCount')));
		
		Test.stopTest();

	}

}