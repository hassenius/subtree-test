/**
 * This file is part of the source code and related artifacts for eGym Application.
 *
 * Copyright © 2013 eGym GmbH
 */
package de.egym.logqueue;

import de.egym.logqueue.writer.EgymLogWriter;

/**
 * This writer implementation always throws an exception.
 */
class FaultyWriter implements EgymLogWriter<String> {
	@Override
	public void write(String logMessage) {
		throw new RuntimeException("This is supposed to fail.");
	}
}
