@isTest
public with sharing class PrepareObjects{
    public static void initTestObjects(List<Opportunity> newOpportunities,Integer numberOfOpportunities,Integer numberOfOtherOpportunities,Integer contactRolesPerOP,Integer numberOfContacts){

        if(numberOfContacts < contactRolesPerOP)
            numberOfContacts = contactRolesPerOP;

        List<Contact> cts = new List<Contact>();
        for(Integer x=0;x<numberOfContacts;x++)
            cts.add(new Contact(LastName ='cttest_'+String.valueOf(x)));
        insert cts;

        newOpportunities.clear();
        for(Integer x=0;x<numberOfOpportunities;x++)
            listOpportunities.add(new Opportunity(Name='test_opp'+String.valueOf(numberOfOpportunities),CloseDate = Date.Today().addDays(5),stageName = 'Prospecting'));
        insert newOpportunities;

        List<Opportunity> otherOpportunities = new List<Opportunity>();
        for(Interger x=0;x<=numberOfOtherOpportunities;x++)
            otherOpportunities.add(new Opportunity(Name='test_opp'+String.valueOf(x+numberOfOtherOpportunities),CloseDate = Date.Today().addDays(5),stageName = 'Prospecting'));
        insert otherOpportunities;

        otherOpportunities.addAll(newOpportunities); // Combine the two for creating OpportunityContactRole

        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        Integer contactNumber = 0;
        for(Opportunity op: otherOpportunities){
            for(Interger ocrNumber=0; ocrNumber<contactRolesPerOP;ocrNumber++){
                ocrList.add(new OpportunityContactRole(OpportunityID = op.Id,ContactId = cts[contactNumber].Id));
                contactNumber++;
                if(contactNumber >= numberOfContacts)
                    contactNumber = 0;
            }
        }
        insert ocrList;
    }

    public static void validateOCRs(List<Opportunity> ops){
        Map<Id,Opportunity> opMap = new Map<Id,Opportunity>(ops); 
        List<Opportunity> opResult = [SELECT ID,(SELECT Id from OpportunityContactRole where IsPrimary=true) from Opportunity where Id IN opMap.keyset()];
        for(Opportunity op: opResult)
            System.Assert(op.OpportunityContactRoles.size() == 1) // make sure every Opportunity has atleast 1 OpportunityContactRole
    }

    static testMethod void bulkOpportunity(){
        List<Opportunity> ops = new List<Opportunity>();
        initTestObjects(ops,100,20,20,40);

        Test.startTest();
        for(Opportunity op: ops)
            op.stageName = 'Qualification';
        update ops;
        Interger numberOfOpportunities = 100;
        List<Opportunity> ops = new List<Opportunity>();
        for(Interger x=0;x<numberOfOpportunities;x++)
            ops.add()
        insert ops;
        List<Task> tasks = [SELECT Id,OwnerId,whatId,status,Subject,Type from Task where OwnerId=:userInfo.getuserId() and Type='Other' and Isclosed = False and Subject = 'Assign Primary contact'];

        System.assertEquals(ops.size(),tasks.size());
        
        Test.stopTest();
        validateOCRs(ops); //test 
    }
}