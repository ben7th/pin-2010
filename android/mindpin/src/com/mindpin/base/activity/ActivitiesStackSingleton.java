package com.mindpin.base.activity;

import java.util.Stack;

// ���ڹ���ͻ���activities�Ķ�ջ������ģʽ
public class ActivitiesStackSingleton {
	private static ActivitiesStackSingleton instance = new ActivitiesStackSingleton();
	
	private Stack<MindpinBaseActivity> activities_stack;
	
	private ActivitiesStackSingleton(){
		activities_stack = new Stack<MindpinBaseActivity>();
	}
	
	private static Stack<MindpinBaseActivity> get_activities_stack(){
		return instance.activities_stack;
	}
	
	// �ر����ж�ջ�е�activity
	protected static void clear_activities_stack(){
		Stack<MindpinBaseActivity> activities_stack = get_activities_stack();
		
		int size = activities_stack.size();
		for(int i=0;i<size;i++){
			MindpinBaseActivity activity = activities_stack.pop();
			activity.finish();
		}
	}
	
	// �Ӷ�ջ���Ƴ�һ��ʵ��
	protected static void remove_activity(MindpinBaseActivity activity){
		get_activities_stack().remove(activity);
	}
	
	
	protected static void tidy_and_push_activity(MindpinBaseActivity new_activity) {
		Class<?> cls = new_activity.getClass();

		// System.out.println(cls + "create");
		// System.out.println("����ǰ��activities��ջ����"+ activities_stack.size()
		// +"��ʵ��");

		// �ȱ���������ͬ���͵� activitiy��������ڣ���������ر�����activity֮�������ʵ��
		// �Ȳ���������ͬ��ʵ�����±�
		Stack<MindpinBaseActivity> activities_stack = get_activities_stack();

		int index = -1;
		int size = activities_stack.size();
		for (int i = 0; i < size; i++) {
			MindpinBaseActivity activity = activities_stack.get(i);
			if (cls == activity.getClass()) {
				index = i;
				break;
			}
		}

		// ����ҵ������֮
		if (index > -1) {
			int pops_count = size - index;
			for (int i = 0; i < pops_count; i++) {
				MindpinBaseActivity item = activities_stack.pop();
				item.finish();
			}
		}
		activities_stack.push(new_activity);

		// System.out.println("�����activities��ջ����"+ activities_stack.size()
		// +"��ʵ��");
	}
}
