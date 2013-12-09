global class FollowMailScheduler implements Schedulable {

	private List<String> targetIds;
	private String templateId;

	/**
	* スケジュール設定
	*/
	public static void submitSchedule( List<String> targetIds , String templateId , DateTime scheduleAt) {
		FollowMailScheduler scheduler = new FollowMailScheduler(targetIds , templateId);
		//スケジュール名が他と被らないように調製
		scheduler.schedule('FollowMailSchedule_' + UserInfo.getUserId() + '_' + DateTime.now().getTime() , 
							scheduleAt);
	}

	//コンストラクタ
	public FollowMailScheduler(List<String> targetIds ,String templateId ) {
		this.targetIds = targetIds;
		this.templateId = templateId;
	}

	//スケジュールメソッド
	private void schedule(String jobName, Datetime scheduleAt) {
		String cron_exp = scheduleAt.format('0 m H d M ? yyyy');
		System.schedule(jobName, cron_exp, this);
	}

	//executeメソッド
	global void execute(SchedulableContext ctx) {
		//メールを送るだけ
		new ContactFollowLogic().sendMail(targetIds , templateId);
		System.abortJob(ctx.getTriggerId());
	}

}