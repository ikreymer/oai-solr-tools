package org.archive.archiveit.oaisolr;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;

import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.solr.client.solrj.ResponseParser;
import org.apache.solr.common.util.NamedList;


/**
 * ClientXsltSolrResponseParser
 * 
 * @contributor ilya
 * 
 * Receive solr XML and perform the XSLT transformation on the client
 */

class ClientXsltSolrResponseParser extends ResponseParser
{
	HttpServletResponse response;
	Transformer transform;
	
	public ClientXsltSolrResponseParser(HttpServletResponse response, Transformer transform) {
		this.response = response;
		this.transform = transform;
	}

	@Override
	public String getWriterType() {
		return "xml";
	}

	@Override
	public NamedList<Object> processResponse(InputStream inStream, String encoding) {
		try {
			
			StreamSource xmlSource = new StreamSource(inStream);
			StreamResult xmlResult = new StreamResult(response.getOutputStream());
			transform.transform(xmlSource, xmlResult);
			
			response.setCharacterEncoding(encoding);
						
		} catch (IOException e) {
			throw new RuntimeException(e);
		} catch (TransformerException e) {
			throw new RuntimeException(e);
		}
		return null;
	}

	@Override
	public NamedList<Object> processResponse(Reader reader) {
		try {
			StreamSource xmlSource = new StreamSource(reader);
			StreamResult xmlResult = new StreamResult(response.getWriter());
			transform.transform(xmlSource, xmlResult);
			
		} catch (IOException e) {
			throw new RuntimeException(e);
		} catch (TransformerException e) {
			throw new RuntimeException(e);
		}
		return null;
	}	
}