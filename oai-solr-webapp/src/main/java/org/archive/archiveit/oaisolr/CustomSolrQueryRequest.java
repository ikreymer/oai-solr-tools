package org.archive.archiveit.oaisolr;

import java.io.IOException;
import java.util.Collection;

import org.apache.solr.client.solrj.ResponseParser;
import org.apache.solr.client.solrj.SolrRequest;
import org.apache.solr.client.solrj.SolrResponse;
import org.apache.solr.client.solrj.SolrServer;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.common.params.SolrParams;
import org.apache.solr.common.util.ContentStream;

class CustomSolrQueryRequest extends SolrRequest
{
	private static final long serialVersionUID = 1L;
	
	private SolrParams params;
	
	public CustomSolrQueryRequest(SolrParams params, ResponseParser writer) {
		super(METHOD.GET, "/select");
		this.params = params;
		this.setResponseParser(writer);
	}		

	@Override
	public SolrResponse process(SolrServer server) throws IOException, SolrServerException {
		server.request(this);
		return null;
	}

	@Override
	public SolrParams getParams() {
		return params;
	}

	@Override
	public Collection<ContentStream> getContentStreams() throws IOException {
		return null;
	}
}