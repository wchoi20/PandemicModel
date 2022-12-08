import random
from bisect import bisect_left

# def calcInfectionsHomes(self, atHomeIDs, Pop, currentInfected):

def BinSearch(a, x):
    '''
    Used to speed up calcInfectionsHomes because Python does a linear search for checking lists
    '''
    i = bisect_left(a, x)
    if i != len(a) and a[i] == x:
        return i
    else:
        return -1

def in_list(item_list, item):
    '''
    Using a binary search to find items in lists, used in calcInfectionsHomes
    '''
    return BinSearch(item_list, item) != -1

def calcInfectionsHomes(atHomeIDs, Pop, currentInfected, generalDebugMode, loopDebugMode, averageHouseholdInfectionRate):
    '''
    Used in the simulation() function. Is responsible for handling the spread of infection within household groups.
    Params:
        atHomeIDs - list of people who are at home
        Pop - list of people in the population
        currentInfected - list of people who are currently infected
    Returns:
        (list): list of people who are infected
    '''
    numperhour = 0
    newlyinfectedathome = []

    # TODO: this math needs to be worked out more, along with correct, scientific numbers

    ##### generalDebugMode #####
    if generalDebugMode:
        print('===master.py/calcInfectionsHomes: currentInfected length is ', len(currentInfected), '===')
    ##### generalDebugMode #####

    # For each person that's currently infected, we have to loop through their household group and calculate the chance that
    # the people they share living spaces with get infected
    for current in currentInfected:

        if in_list(atHomeIDs, current.getID()) and 0 <= current.getInfectionState() <= 3:
            household_group = list(
                current.getHouseholdMembers())  #id's #someone should check that this list is behaving 7/14
            r = random.randint(1, 24)
            if r <= 2:
                # Right now, r determines the chance that someone in household_group gets put on infection track
                neighborhouse = list(current.getextendedhousehold())[
                    random.randint(0, len(current.getextendedhousehold()) - 1)]
                for each in Pop[neighborhouse].getHouseholdMembers():
                    household_group.append(each)

            for each in household_group:

                ##### loopDebugMode #####
                if loopDebugMode:
                    print('===master.py/calcInfectionsHomes: looping household_group===')
                ##### loopDebugMode #####

                if len(Pop[each].getInfectionTrack()) > 0:
                    continue
                if (Pop[each].getVaccinatedStatus()):
                    householdRandomVariable = 20 * random.random()  # Multiplying by 20 increases householdRandomVariable, decreasing the chance of infection
                else:
                    householdRandomVariable = random.random()

                if (householdRandomVariable < (averageHouseholdInfectionRate / (24 * (len(
                        current.getInfectionTrack()) - current.getIncubation()))) and in_list(atHomeIDs,
                                                                                                   each)):  # Probability of infection if in same house at the moment
                    Pop[each].assignTrajectory()
                    newlyinfectedathome.append(Pop[each])
                    numperhour += 1

    return newlyinfectedathome