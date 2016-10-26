/**
 * This file is part of the source code and related artifacts for eGym Application.
 *
 * Copyright © 2013 eGym GmbH
 */
package de.egym.logqueue.decorator;

import net.jcip.annotations.ThreadSafe;

import com.google.inject.Singleton;
import de.egym.logqueue.EgymLogRequestRecord;

/**
 * This is a simple pass-through or no-op decorator implementation. It does not add any information to the record.
 */
@Singleton
@ThreadSafe
public class EgymLogNoOpDecorator implements EgymLogDecorator<EgymLogRequestRecord> {
	@Override
	public EgymLogRequestRecord decorate(EgymLogRequestRecord requestRecord) {
		return requestRecord;
	}
}
