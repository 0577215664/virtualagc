### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	PHASE_TABLE_MAINTENANCE.agc
# Purpose:	Part of the source code for Artemis (i.e., Colossus 3),
#		build 072.  This is for the Command Module's (CM)
#		Apollo Guidance Computer (AGC), we believe for
#		Apollo 15-17.
# Assembler:	yaYUL
# Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:	www.ibiblio.org/apollo/index.html
# Page Scans:	www.ibiblio.org/apollo/ScansForConversion/Artemis072/
# Mod history:	2009-08-18 JL	Adapted from corresponding Comanche 055 file.
#		2010-02-20 RSB	Un-##'d this header.

## Page 1402

# SUBROUTINE TO UPDATE THE PROGRAM NUMBER DISPLAY ON THE DSKY.

		SETLOC	FFTAG1
		BANK

		COUNT*	$$/PHASE
NEWMODEX	INDEX	Q		# UPDATE MODREG. ENTRY FOR MODE IN FIXED.
		CAF	0
		INCR	Q

NEWMODEA	TS	MODREG		# ENTRY FOR MODE IN A.
MMDSPLAY	CAF	+3		# DISPLAY MAJOR MODE.
PREBJUMP	LXCH	BBANK		# PUTS BBANK IN L
		TCF	BANKJUMP	# PUTS Q INTO A
		CADR	SETUPDSP

# RETURN TO CALLER +3 IF MODE = THAT AT CALLER +1. OTHERWISE RETURN TO CALLER +2.

CHECKMM		INDEX	Q
		CS	0
		AD	MODREG
		EXTEND
		BZF	Q+2
		TCF	Q+1		# NO MATCH

		SETLOC	PHASETAB
		BANK

		COUNT*	$$/PHASE
SETUPDSP	INHINT
		DXCH	RUPTREG1	# SAVE CALLER'S RETURN 2CADR
		TC	NOVAC30		# EITHER A TASK OR JOB CAN COME TO NEWMODEX
		EBANK=	MODREG
		2CADR	DSPMMJOB

		DXCH	RUPTREG1
		RELINT
		DXCH	Z		# RETURN

DSPMMJOB	EQUALS	DSPMMJB

		SETLOC	FFTAG1
		BANK
## Page 1403

# PHASCHNG IS THE MAIN WAY OF MAKING PHASE CHANGES FOR RESTARTS.  THERE ARE THREE FORMS OF PHASCHNG, KNOWN AS TYPE
# A, TYPE B, AND TYPE C. THEY ARE ALL CALLED AS FOLLOWS, WHERE OCT XXXXX CONTAINS THE PHASE INFORMATION,
#
#		TC	PHASCHNG
#		OCT	XXXXX
#
# TYPE A IS CONCERNED WITH FIXED PHASE CHANGES, THAT IS, PHASE INFORMATION THAT IS STORED PERMANENTLY.  THESE
# OPTIONS ARE, WHERE G STANDS FOR A GROUP AND .X FOR THE PHASE,
#
#	G.0		INACTIVE, WILL NOT PERMIT A GROUP G RESTART
#	G.1		WILL CAUSE THE LAST DISPLAY TO BE REACTIVATED, USED MAINLY IN MANNED FLIGHTS
#	G.EVEN		A DOUBLE TABLE RESTART, CAN CAUSE ANY COMBINATION OF TWO JOBS, TASKS, AND/OR
#			LONGCALL TO BE RESTARTED.
#	G.ODD NOT .1	A SINGLE TABLE RESTART, CAN CAUSE EITHER A JOB, TASK, OR LONGCALL RESTART
#
# THIS INFORMATION IS PUT INTO THE OCTAL WORD AFTER TC PHASCHNG AS FOLLOWS
#
#	TL0 00P PPP PPP GGG
#
# WHERE EACH LETTER OR NUMBER STANDS FOR A BIT.  THE G'S STAND FOR THE GROUP, OCTAL 1 - 7, THE P'S FOR THE PHASE,
# OCTAL 0 - 127.  0'S MUST BE 0.              IF ONE WISHES TO HAVE THE TBASE OF GROUP G TO BE SET AT THIS TIME,
# T IS SET TO 1, OTHERWISE IT IS SET TO 0.  SIMILARLY IF ONE WISHES TO SET LONGBASE, THEN L IS SET TO 1, OTHERWISE
# IT IS SET TO 0.  SOME EXAMLES,
#
#		TC	PHASCHNG	# THIS WILL CAUSE GROUP 3 TO BE SET TO 0,
#		OCT	00003		# MAKING GROUP 3 INACTIVE
#
#		TC	PHASCHNG	# IF A RESTART OCCURS THIS WOULD CAUSE
#		OCT	00012		# GROUP 2 TO RESTART THE LAST DISPLAY
#
#		TC	PHASCHNG	# THIS SETS THE TBASE OF GROUP 4 AND IN
#		OCT	40064		# CASE OF A RESTART WOULD START UP THE TWO
#					# THINGS LOCATED IN THE DOUBLE 4.6 RESTART
#					# LOCATION.
#		TC	PHASCHNG	# THIS SETS LONGBASE AND UPON A RESTART
#		OCT	20135		# CAUSES 5.13 TO BE RESTARTED (SINCE
#					# LONGBASE WAS SET THIS SINGLE ENTRY
#					# SHOULD BE A LONGCALL)
#		TC	PHASCHNG	# SINCE BOTH TBASE4 AND LONGBASE ARE SET,
#		OCT	60124		# 4.12 SHOULD CONTAIN BOTH A TASK AND A
#					# LONGCALL TO BE RESTARTED
#
# TYPE C PHASCHNG CONTAINS THE VARIABLE TYPE OF PHASCHNG INFORMATION.  INSTEAD OF THE INFORMATION BEING IN A
# PERMANENT FORM, ONE STORES THE DESIRED RESTART INFORMATION IN A VARIABLE LOCATION. THE BITS ARE AS FOLLOWS,
#
#	TL0 1AD XXX CJW GGG
#
# WHERE EACH LETTER OR NUMBER STANDS FOR A BIT.  THE G'S STAND FOR THE GROUP, OCTAL 1 - 7.  IF THE RESTART IS TO
# BE BY WAITLIST, W IS SET TO 1, IF IT IS A JOB, J IS SET TO 1, IF IT IS A LONGCALL, C IS SET TO 1. ONLY ONE OF
# THESE THREE BITS MAY BE SET.  X'S ARE IGNORED, 1 MUST BE 1, AND 0 MUST BE 0.  AGAIN T STANDS FOR THE TBASE,
## Page 1404
# AND L FOR LONGBASE.  THE BITS A AND D ARE CONCERNED WITH THE VARIABLE INFORMATION. IF D IS SET TO 1, A PRIORITY
# OR DELTA TIME WILL BE READ FROM THE NEXT LOCATION AFTER THE OCTAL INFORMATION, IF THIS IS TO BE INDIRECT, THAT
# IS, THE NAME OF A LOCATION CONTAINING THE INFORMATION (DELTA TIME ONLY), THEN THIS IS GIVEN AS THE -GENADR OF
# THAT LOCATION WHICH CONTAINS THE DELTA TIME.  IF THE OLD PRIORITY OR DELTA TIME IS TO BE USED, THAT WHICH IS
# ALREADY IN THE VARIABLE STORAGE, THEN D IS SET TO 0. NEXT THE A BIT IS USED.  IF IT IS SET TO 0, THE ADDRESS
# THAT WOULD BE RESTARTED DURING A RESTART IS THE NEXT LOCATION AFTER THE PHASE INFORMATION, THAT IS, EITHER
# (TC PHASCHNG) +2 OR +3, DEPENDING ON WHETHER D HAD BEEN SET OR NOT.  IF A IS SET TO 1, THEN THE ADDRESS THAT
# WOULD BE RESTARTED IS THE 2CADR THAT IS READ FROM THE NEXT TWO LOCATION.  EXAMPLES,
#
#	AD	TC	PHASCHNG	# THIS WOULD CAUSE LOCATION AD +3 TO BE
#	AD+1	OCT	05023		# RESTARTED BY GROUP THREE WITH A PRIORITY
#	AD+2	OCT	23000		# OF 23.  NOTE UPON RETURNING IT WOULD
#	AD+3				# ALSO GO TO AD+3
#
#	AD	TC	PHASCHNG	# GROUP  1 WOULD CAUSE CALLCALL TO BE
#	AD+1	OCT	27441		# BE STARTED AS A LONGCALL FROM THE TIME
#	AD+2   -GENADR	DELTIME		# STORED IN LONGBASE (LONGBASE WAS SET) BY
#	AD+3	2CADR	CALLCALL	# A DELTATIME STORED IN DELTIME.  THE
#	AD+4				# BBCON OF THE 2CADR SHOULD CONTAIN THE E
#	AD+5				# BANK OF DELTIME. PHASCHNG RETURNS TO
#					# LOCATION AD+5
#
# NOTE THAT IF A VARIABLE PRIORITY IS GIVEN FOR A JOB, THE JOB WILL BE RESTARTED AS A NOVAC IF THE PRIORITY IS
# NEGATIVE, AS A FINDVAC IF THE PRIORITY IS POSITIVE.
#
# TYPE B PHASCHNG IS A COMBINATION OF VARIABLE AND FIXED PHASE CHANGES. IT WILL START UP A JOB AS INDICATED
# BELOW AND ALSO START UP ONE FIXED RESTART, THAT IS EITHER AN G.1 OR A G.ODD OR THE FIRST ENTRY OF G.EVEN
# DOUBLE ENTRY.  THE BIT INFORMATION IS AS FOLLOW,
#
#	TL1 DAP PPP PPP GGG
#
# WHERE EACH LETTER OR NUMBER STANDS FOR A BIT.  THE G'S STAND FOR THE GROUP, OCTAL 1 - 7, THE P'S FOR THE FIXED
# PHASE INFORMATION, OCTAL 0 - 127. 1 MUST BE 1.  AND AGAIN T STANDS FOR THE TBASE AND L FOR LONGBASE.  D THIS
# TIME STANDS ONLY FOR PRIORITY SINCE THIS WILL BE CONSIDERED A JOB, AND IT MUST BE GIVEN DIRECTLY IF GIVEN.
# AGAIN A STANDS FOR THE ADDRESS OF THE LOCATION TO BE RESTARTED, 1 IF THE 2CADR IS GIVEN, OR 0 IF IT IS TO BE
# THE NEXT LOCATION.(THE RETURN LOCATION OF PHASCHNG) EXAMPLES,
#
#	AD	TC	PHASCHNG	# TBASE IS SET AND A RESTART CAUSE GROUP 3
#	AD+1	OCT	56043		# TO START THE JOB AJOBAJOB WITH PRIORITY
#	AD+2	OCT	31000		# 31 AND THE FIRST ENTRY OF 3.4SPOT (WE CAN
#	AD+3	2CADR	AJOBAJOB	# ASSUME IT IS A TASK SINCE WE SET TBASE3)
#	AD+4				# UPON RETURN FROM PHASCHNG CONTROL WOULD
#	AD+5				# GO TO AD+5
#
#	AD	TC	PHASCHNG	# UPON A RESTART THE LAST DISPLAY WOULD BE
#	AD+1	OCT	10015		# RESTARTED AND A JOB WITH THE PREVIOUSLY
#	AD+2				# STORED PRIORITY WOULD BE BEGUN AT AD+2
#					# BY MEANS OF GROUP 5

## Page 1405

# THE NOVAC-FINDVAC CHOICE FOR JOBS HOLDS HERE ALSO - NEGATIVE PRIORITY CAUSES A NOVAC CALL, POSITIVE A FINDVAC.
#
#
# SUMMARY OF BITS:
#
# TYPE A		TL0 00P PPP PPP GGG
#
# TYPE B		TL1 DAP PPP PPP GGG
#
# TYPE C		TL0 1AD XXX CJW GGG
#

## Page 1406

# 2PHSCHNG IS USED WHEN ONE WISHES TO START UP A GROUP OR CHANGE A GROUP WHILE UNDER THE CONTROL OF A DIFFERENT
# GROUP. FOR EXAMPLE, CHANGE THE PHASE OF GROUP 3 WHILE THE PORTION OF THE PROGRAM IS UNDER GROUP 5. ALL 2PHSCHNG
# CALLS ARE MADE IN THE FOLLOWING MANNER,
#
#		TC	2PHSCHNG
#		OCT	XXXXX
#		OCT	YYYYY
#
# WHERE OCT XXXXX MUST BE OF TYPE A AND OCT YYYYY MAY BE OF EITHER TYPE A OR TYPE B OR TYPE C.  THERE IS ONE
# DIFFERENCE --- NOTE- IF LONGBASE IS TO BE SET THIS INFORMATION IS GIVEN IN THE OCT YYYYY INFORMATION, IT WILL
# BE DISREGARDED IF GIVEN WITH THE OCT XXXXX INFORMATION. A COUPLE OF EXAMPLES MAY HELP,
#
#	AD	TC	2PHACHNG	# SET TBASE3 AND IF A RESTART OCCURS START
#	AD+1	OCT	40083		# THE TWO ENTRIES IN 3.8 TABLE LOCATION
#	AD+2	OCT	05025		# THIS IS OF TYPE C, SET THE JOB TO BE
#	AD+3	OCT	18000		# TO BE LOCATION AD+4, WITH A PRIORITY 18,
#	AD+4				# FOR GROUP 5 PHASE INFORMATION.

		COUNT*	$$/PHASE
2PHSCHNG	INHINT			# THE ENTRY FOR A DOUBLE PHASE CHANGE
		NDX	Q
		CA	0
		INCR	Q
		TS	TEMPP2

		MASK	OCT7
		DOUBLE
		TS	TEMPG2

		CA	TEMPP2
		MASK	OCT17770	# NEED ONLY 1770, BUT WHY GET A NEW CONST.
		EXTEND
		MP	BIT12
		XCH	TEMPP2

		MASK	BIT15
		TS	TEMPSW2		# INDICATES WHETHER TO SET TBASE OR NOT

		TCF	PHASCHNG +3

PHASCHNG	INHINT
		CA	ONE		# INDICATES CAME FROM A PHASCHNG ENTRY
		TS	TEMPSW2
		
 +3		NDX	Q
		CA	0
		INCR	Q
		TS	TEMPSW
## Page 1407
		EXTEND
		DCA	ADRPCHN2	# OFF TO SWITCHED BANK
		DTCB

		EBANK=	LST1
ADRPCHN2	2CADR	PHSCHNG2


ONEORTWO	LXCH	TEMPBBCN
		LXCH	BBANK
		LXCH	TEMPBBCN

		MASK	OCT14000	# SEE WHAT KIND OF PHASE CHANGE IT IS
		CCS	A
		TCF	CHECKB		# IT IS OF TYPE 'B'.

		CA	TEMPP
		MASK	BIT7
		CCS	A		# SHALL WE USE THE OLD PRIORITY
		TCF	GETPRIO		# NO GET A NEW PRIORITY (OR DELTA T)

OLDPRIO		NDX	TEMPG		# USE THE OLD PRIORITY (OR DELTA T)
		CA	PHSPRDT1 -2
 -1		TS	TEMPPR

CON1		CA	TEMPP		# SEE IF A 2CADR IS GIVEN
		MASK 	BIT8
		CCS	A
		TCF	GETNEWNM

		CA	Q
		TS	TEMPNM
		CA	BB
		EXTEND			# PICK UP USERS SUPERBANK
		ROR	SUPERBNK
		TS	TEMPBB

TOCON2		CA	CON2ADR		# BACK TO SWITCHED BANK
		LXCH	TEMPBBCN
		DTCB

CON2ADR		GENADR	CON2

GETPRIO		NDX	Q		# DON'T CARE IF DIRECT OR INDIRECT
		CA	0		# LEAVE THAT DECISION TO RESTARTS
		INCR	Q		# OBTAIN RETURN ADDRESS
		TCF	CON1 -1

GETNEWNM	EXTEND
## Page 1408
		INDEX	Q
		DCA	0
		DXCH	TEMPNM
		CA	TWO
		ADS	Q		# OBTAIN RETURN ADDRESS

		TCF	TOCON2

OCT14000	EQUALS	PRIO14
TEMPG		EQUALS	ITEMP1
TEMPP		EQUALS	ITEMP2
TEMPNM		EQUALS	ITEMP3
TEMPBB		EQUALS	ITEMP4
TEMPSW		EQUALS	ITEMP5
TEMPSW2		EQUALS	ITEMP6
TEMPPR		EQUALS	RUPTREG1
TEMPG2		EQUALS	RUPTREG2
TEMPP2		EQUALS	RUPTREG3

TEMPBBCN	EQUALS	RUPTREG4
BB		EQUALS	BBANK

		SETLOC	PHASETAB
		BANK

		EBANK=	PHSNAME1
		COUNT*	$$/PHASE
PHSCHNG2	LXCH	TEMPBBCN
		CA	TEMPSW
		MASK	OCT7
		DOUBLE
		TS	TEMPG

		CA	TEMPSW
		MASK	OCT17770
		EXTEND
		MP	BIT12
		TS	TEMPP

		CA	TEMPSW
		MASK	OCT60000
		XCH	TEMPSW
		MASK	OCT14000
		CCS	A

		TCF	ONEORTWO

		CA	TEMPP		# START STORING THE PHASE INFORMATION
		NDX	TEMPG
## Page 1409
		TS	PHASE1 -2

BELOW1		CCS	TEMPSW2		# IS IT A PHASCHNG OR A 2PHSCHNG
		TCF	BELOW2		# IT'S A PHASCHNG

		TCF	+1		# IT'S A 2PHSCHNG
		CS	TEMPP2
		LXCH	TEMPP2
		NDX	TEMPG2
		DXCH	-PHASE1 -2

		CCS	TEMPSW2
		NOOP			# CAN'T GET HERE
		TCF	BELOW2

		CS	TIME1
		NDX	TEMPG2
		TS	TBASE1 -2

BELOW2		CCS	TEMPSW		# SEE IF WE SHOULD SET TBASE OR LONGBASE
		TCF	BELOW3		# SET LONGBASE ONLY
		TCF	BELOW4		# SET NEITHER

		CS	TIME1		# SET TBASE TO BEGIN WITH
		NDX	TEMPG
		TS	TBASE1 -2

		CA	TEMPSW		# SHALL WE NOW SET LONGBASE
		AD	BIT14COM
		CCS	A
		NOOP			# ***** CANT GET HERE *****
BIT14COM	OCT	17777		# ***** CANT GET HERE *****
		TCF	BELOW4		# NO WE NEED ONLY SET TBASE

BELOW3		EXTEND			# SET LONGBASE
		DCA	TIME2
		DXCH	LONGBASE

BELOW4		CS	TEMPP		# AND STORE THE FINAL PART OF THE PHASE
		NDX	TEMPG
		TS	-PHASE1 -2

		CA	Q
		LXCH	TEMPBBCN
		RELINT
		DTCB
CON2		LXCH	TEMPBBCN

		CA	TEMPP
		NDX	TEMPG
## Page 1410
		TS	PHASE1 -2

		CA	TEMPPR
		NDX	TEMPG
		TS	PHSPRDT1 -2

		EXTEND
		DCA	TEMPNM
		NDX	TEMPG
		DXCH	PHSNAME1 -2

		TCF	BELOW1

		SETLOC	FFTAG1
		BANK

		COUNT*	$$/PHASE
CHECKB		MASK	BIT12		# SINCE THIS IS OF TYPE B, THIS BIT SHOULD
		CCS	A		# BE HERE IF WE ARE TO GET A NEW PRIORITY
		TCF	GETPRIO		# IT IS, SO GET NEW PRIORITY

		TCF	OLDPRIO		# IT ISN'T, USE THE OLD PRIORITY.