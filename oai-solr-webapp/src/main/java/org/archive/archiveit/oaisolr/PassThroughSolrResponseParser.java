package org.archive.archiveit.oaisolr;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;

import javax.servlet.http.HttpServletResponse;

import org.apache.solr.client.solrj.ResponseParser;
import org.apache.solr.common.util.NamedList;
import org.springframework.util.FileCopyUtils;

class PassThroughSolrResponseParser extends ResponseParser
{
	HttpServletResponse response;
	
	public PassThroughSolrResponseParser(HttpServletResponse response) {
		this.response = response;
	}

	@Override
	public String getWriterType() {
		return "xslt";
	}

	@Override
	public NamedList<Object> processResponse(InputStream inStream, String encoding) {
		try {
			FileCopyUtils.copy(inStream, response.getOutputStream());
			response.setCharacterEncoding(encoding);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
		return null;
	}

	@Override
	public NamedList<Object> processResponse(Reader reader) {
		try {
			FileCopyUtils.copy(reader, response.getWriter());
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
		return null;
	}	
}