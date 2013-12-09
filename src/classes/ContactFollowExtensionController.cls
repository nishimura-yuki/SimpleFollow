public with sharing class ContactFollowExtensionController {

	public List<SelectOption> templateSelect{ get; set; }

	public String selection { get; set; }
	public Contact recipient  { get; set; }

	public ContactFollowExtensionController(ApexPages.StandardController stdController) {
		recipient = (Contact)stdController.getRecord();
	}
	
	public void init(){
		//メールテンプレート取得
		List<EmailTemplate> tempList = new ContactFollowLogic().getTemplate();

		//ラジオボタン設定
		List<SelectOption> options = new List<SelectOption>();
		for(EmailTemplate e : tempList){
			options.add(new SelectOption(e.Id, e.Name));
		}
		templateSelect = options;
		selection = null;
		if(tempList.size() > 0){
			selection = tempList.get(0).Id;
		}
	}

	public PageReference reservedsend() {
		//スケジュールを予約する
		new ContactFollowLogic().reserveMail(new List<String>{recipient.Id} , selection);
		return Page.PublisherContactFollowFinish;
	}

	public PageReference directsend() {
		//即時で送る
		new ContactFollowLogic().sendMail(new List<String>{recipient.Id} , selection);
		return Page.PublisherContactFollowFinish;
	}

}