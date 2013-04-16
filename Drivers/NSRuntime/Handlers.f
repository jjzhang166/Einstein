/*	Project:	Einstein NS Runtime	File:		Handlers.f*/knownGlobalFunctions.ClearVBOCache := 1;knownGlobalFunctions.ConvertToUniStr := 2;knownGlobalFunctions.|Einstein:Log| := 1;DefConst('kMyPrint,func( object )begin	if IsString(object) then	Write("\"" & object & "\"\n")	else if IsSymbol(object) then	Write("'" & object & "\n")	else if IsArray(object) then	Write("Array<" & Length(object) & ">\n")	else if IsFrame(object) then	Write("Frame<" & Length(object) & ">\n")	else if IsBinary(object) then	Write("Binary<" & Length(object) & ">\n")	else if (object = TRUE) then	Write("TRUE\n")	else if (object = NIL) then	Write("NIL\n")	else if IsInteger(object) then	Write(object & "\n")	else Write("Unknown<" & object & ">\n");end);DefConst('kMyWrite,func( what )begin	|Einstein:Log|(what);end);DefConst('kNotifyIconActionFn,func(view)begin	view:Show();	RemoveSlot(view, 'action);end);DefConst('kCloseBoxButtonScriptFn,func()begin	base.action := 		GetRoot().notifyIcon:AddAction(			base.actionText, kNotifyIconActionFn, [base]);	base:Hide();end);DefConst('kEvaluateNSFn,func( id, size )begin	// Get the whole binary at once.	local theBinary := call NSRuntime.CopyBufferData with (id, 0, size);	call NSRuntime.DisposeBuffer with (id);	if (theBinary)	then	begin		local theStr := ConvertToUniStr(theBinary, 'ISO88591);		try			local theResult := call Compile(theStr) with ();			Print(theResult);		onexception |ex| do		begin			Write("Exception\n");			Print(CurrentException());		end;	end else begin		Write("Couldn't get the binary!");	end;end);DefConst('kDoInstallPackageFn2,func(binary)begin	local size := Length(binary);	local myOpts := {			closeBox: nil,			gauge: 0,			statusText: "Installing package...",			titleText: "..."		};	DoProgress('vGauge,		myOpts,		func(view)		begin			GetDefaultStore():SuckPackageFromBinary(binary,			{				callbackFrequency: size DIV 100,				callback:					func(progress)					begin						myOpts.gauge := progress.amountRead * 100 DIV progress.packageSize;						myOpts.titleText := progress.packageName &&							"[" & (progress.currentPartNumber + 1)							& "/" & progress.numberOfParts & "]";						view:SetStatus('vGauge, myOpts);					end			});		end);end);DefConst('kDoInstallPackageFn,func( id, size )begin	// Create a VBO.	local theBinary := GetDefaultStore():NewVBO('package, size);		local myOpts := {			closeBox: nil,			gauge: [0, 0, size],			statusText: "Transferring package...",		};	DoProgress('vGauge,		myOpts,		func(view)		begin			// Iterate.			local theChunkSize := 8192;			local theOffset := 0;			while (theOffset < size) do			begin				if (theOffset + theChunkSize > size) then					theChunkSize := size - theOffset;								local theChunk :=					call NSRuntime.CopyBufferData with (id, theOffset, theChunkSize);				BinaryMunger(theBinary,theOffset,theChunkSize,theChunk,0,theChunkSize);				ClearVBOCache(theBinary);								theOffset := theOffset + theChunkSize;				myOpts.gauge := theOffset;				view:SetStatus('vGauge, myOpts);			end;		end);	call NSRuntime.DisposeBuffer with (id);	AddDeferredCall(kDoInstallPackageFn2, [theBinary]);end);DefConst('kInstallPackageFn,func( id, size )begin	AddDeferredCall(kDoInstallPackageFn, [id, size]);end);