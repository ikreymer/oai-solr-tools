package org.archive.archiveit.oaisolr;

import java.io.IOException;
import java.net.ConnectException;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;

import org.apache.solr.client.solrj.ResponseParser;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.CommonsHttpSolrServer;
import org.apache.solr.common.SolrException;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class OAIController implements ApplicationContextAware {
	
	/**
	 * Enum of OAI Verbs for the "verb=" parameter
	 * (Invalid verb gets mapped to Identify)
	 *
	 */

	enum Verb {
		Identify, 
		ListMetadataFormats, 
		GetRecord, 
		ListRecords,
		ListIdentifiers, 
		ListSets,
	}
	
	final static String EMPTY_STRING = "";
	
	final static String METADATA_PREFIX = "metadataPrefix";
	final static String IDENTIFIER = "identifier";
	final static String VERB = "verb";
	final static String FROM = "from";
	final static String UNTIL = "until";
	final static String SET = "set";
	final static String RESUMPTION_TOKEN = "resumptionToken";
	
	final static String[] errorTypes = 
	{"badArgument", "badVerb", "cannotDisseminateFormat",
		"idDoesNotExist", "noRecordsMatch", "noSetHierarchy", "cannotDisseminateFormat2"};
		
	
	final static String[] resumptionParams = {"start", "rows", METADATA_PREFIX, FROM, UNTIL};
	
	protected CommonsHttpSolrServer solrServer;
	
	@Autowired(required = false)	
	public OAIController(String url, XsltHandler clientXsltHandler) {
		this.solrServer = null; // server will be created on first use
		this.solrServerUrl = url;
		this.clientXsltHandler = clientXsltHandler;
	}
	
	@Autowired(required = false)
	public OAIController(CommonsHttpSolrServer solrServer, XsltHandler clientXsltHandler) {
		this.solrServer = solrServer;
		this.solrServerUrl = solrServer.getBaseURL();
		this.clientXsltHandler = clientXsltHandler;		
	}
	
	protected TransformerFactory transformerFactory;
	protected XsltHandler clientXsltHandler;
	
	protected ApplicationContext appContext;
	
	// Properties
	protected String solrServerUrl = "http://localhost:8983/solr";
	
	protected String identifierPrefix = EMPTY_STRING;
	protected String xsltPath = EMPTY_STRING;

	protected int numResultsToDisplay = 10;

	protected String collectionIdField;
	
	protected String[] filterQueries;

	protected String datestampField;
	
	protected String setPrefix;
	protected String setIdField;
	protected String setNameField;
	protected String setDescField;
	protected String[] setQueries;
	
	@ExceptionHandler(value = {SolrException.class, SolrServerException.class})
	public void handleException(Exception ex, HttpServletRequest request, HttpServletResponse response) throws IOException {	
		
		String msg;
		
		if (ex instanceof SolrException) {
			msg = ex.getLocalizedMessage();
			// Don't send the request as part of error msg
			int requestStart = msg.indexOf("request:");
			if (requestStart > 0) {
				msg = msg.substring(0, requestStart);
			}
		} else if (ex instanceof SolrServerException) {
			msg = appContext.getMessage("oai.solr.unavailable", null, Locale.getDefault());
		} else {
			msg = ex.getLocalizedMessage();
		}
		
		if (clientXsltHandler != null) {
			clientXsltHandler.sendErrorXml(response, msg, request.getRequestURL().toString());
			ex.printStackTrace();
		} else {
			response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE, msg);	
		}
	}

	@RequestMapping(value = "", method = { RequestMethod.GET, RequestMethod.POST })
	public void handleOAI(@RequestParam(value = VERB, defaultValue = EMPTY_STRING) String verbName,
						  @RequestParam(value = IDENTIFIER, required = false) String identifier,
						  @RequestParam(value = METADATA_PREFIX, defaultValue = EMPTY_STRING) String metadataPrefix,
						  @RequestParam(value = FROM, required = false) String from,
						  @RequestParam(value = UNTIL, required = false) String until,
						  @RequestParam(value = SET, required = false) String set,
						  @RequestParam(value = RESUMPTION_TOKEN, required = false) String resumptionToken,
			HttpServletRequest  request,
			HttpServletResponse response) throws IOException, ConnectException, SolrServerException, TransformerConfigurationException {
		
		Verb theVerb;

		try {
			theVerb = Verb.valueOf(verbName);
		} catch (NullPointerException e) {
			theVerb = Verb.Identify;
		} catch (IllegalArgumentException e) {
			theVerb = Verb.Identify;
		}
		
		SolrQuery query = new SolrQuery();
		query.set("echoParams", "all");
		
		if (clientXsltHandler == null) {
			query.set("tr", String.format(xsltPath, verbName));
		}
		
		query.set(VERB, verbName);
		query.set("requestStr", request.getRequestURL().toString());
		query.setQuery("*:*");
		
		Locale locale = Locale.getDefault();
		
		for (String errorType : errorTypes)
		{
			addErrorQuery(errorType, query, locale);
		}
				
		switch (theVerb)
		{
		case ListIdentifiers:
			query.setFields(collectionIdField, datestampField, setIdField);
			//No Break, extra constraint adding to below query constraints
			
		case ListRecords:
		case GetRecord:
			query.set("collectionIdField", collectionIdField);
			query.set("datestampField", datestampField);
			
			for (String filter : filterQueries) {
				query.addFilterQuery(filter);
			}

			if (metadataPrefix != null) {
				query.set(METADATA_PREFIX, metadataPrefix);
			}
			
			break;
		}
		
		switch (theVerb)
		{
		case Identify:
		case ListMetadataFormats:
			query.setRows(0);
			break;
			
		case GetRecord:			
			query.setRows(0);
			
			if (identifier != null) {
				query.set(IDENTIFIER, identifier);
				
				if (identifier.startsWith(identifierPrefix)) {
					String collStr = identifier.substring(identifierPrefix.length());
					try {
						// This is to ensure that collId is a valid number
						query.setQuery(collectionIdField + ":" + Integer.parseInt(collStr));
						query.setRows(1);
					} catch (NumberFormatException n)
					{
						//just skip setting query, solr will detect missing collection since there
						// are 0 rows
					}
				}
			}	
			break;
			
		case ListIdentifiers:
		case ListRecords:
			query.set(IDENTIFIER, identifierPrefix);
			
			if (resumptionToken != null) {
				processResumptionToken(query, resumptionToken);
				from = query.get(FROM, null);
				until = query.get(UNTIL, null);
			} else {
				query.setRows(numResultsToDisplay);
				
				if (from != null) {
					query.set(FROM, from);					
				}
				
				if (until != null) {
					query.set(UNTIL, until);
				}
			}
			
			if (datestampField != null) {
				processDateRange(query, from, until);
			}
			

			if (setIdField != null) {
				query.set("setIdField", setIdField);
				
				if (set != null) {		
					if (setPrefix != null) {
						if (set.startsWith(setPrefix + ":")) {
							set = set.substring(setPrefix.length() + 1);
						} else {
							query.setRows(0);
						}
					}
					
					query.set(SET, set);
					
					try {
						// This is to ensure that set is a number
						query.addFilterQuery(setIdField + ":" + Integer.parseInt(set));
					} catch (NumberFormatException n) {
						query.setRows(0);
					}
				}
			}
			
			if (setPrefix != null) {			
				query.set("setPrefix", setPrefix);
			}			
			break;
			
		case ListSets:
			query.set("setIdField", setIdField);
			query.set("setNameField", setNameField);
			query.set("setDescField", setDescField);
			query.set("setPrefix", setPrefix);
			query.set(RESUMPTION_TOKEN, resumptionToken);
			query.setFields(setIdField, setNameField, setDescField);
			query.setRows(numResultsToDisplay);
			
			for (String setQuery : setQueries) {
				query.addFilterQuery(setQuery);
			}
			
			if (resumptionToken != null) {
				processResumptionToken(query, resumptionToken);
			}
			break;
		}
		
		response.setContentType("text/xml");
	
		ResponseParser parser = null;
		
		if (clientXsltHandler != null) {
			parser = clientXsltHandler.newParserInstance(response);
		} else {
			parser = new PassThroughSolrResponseParser(response);
		}
		
		System.out.println("Solr Query: " + query.toString());
		
		CustomSolrQueryRequest req = new CustomSolrQueryRequest(query, parser);
		
		if (solrServer == null) {
			solrServer = new CommonsHttpSolrServer(solrServerUrl);
		}
		
		req.process(solrServer);
	}
	
	protected void addErrorQuery(String errorType, SolrQuery query, Locale locale)
	{
		query.set(errorType, appContext.getMessage("error." + errorType, null, locale));		
	}

	protected void processResumptionToken(SolrQuery query, String token) {
		query.set(RESUMPTION_TOKEN, token);
		
		String tokens[] = token.split(",");
		
		for (int i = 0; i < tokens.length; i++)
		{
			if (i >= resumptionParams.length) {
				break;
			}
			
			query.set(resumptionParams[i], tokens[i]);
		}
	}
	
	protected void processDateRange(SolrQuery query, String from, String until)
	{
		if (datestampField != null && ((from != null) || (until != null))) {
			if ((from == null) || from.isEmpty()) {
				from = "*";
			}
			
			if ((until == null) || until.isEmpty()) {
				until = "*";
			}
			
			query.addFilterQuery(String.format("%s:[%s TO %s]", datestampField, from, until));
		}		
	}
	
	// Getter / Setters
	public String getSolrServerUrl()
	{
		return solrServerUrl;
	}
	
	public void setSolrServerUrl(String solrServerUrl)
	{
		if (solrServer != null) {
			solrServer.setBaseURL(solrServerUrl);
		}
		
		this.solrServerUrl = solrServerUrl;
	}
	
	public CommonsHttpSolrServer getSolrServer() {
		return solrServer;
	}
	
	public String getIdentifierPrefix() {
		return identifierPrefix;
	}

	public void setIdentifierPrefix(String identifierPrefix) {
		this.identifierPrefix = identifierPrefix;
	}
	
	public String getXsltPath() {
		return xsltPath;
	}

	public void setXsltPath(String xsltPath) {
		this.xsltPath = xsltPath;
		
		if (clientXsltHandler != null) {
			clientXsltHandler.setXsltPath(this.xsltPath);
		}
	}
	
	public int getNumResultsToDisplay() {
		return numResultsToDisplay;
	}

	public void setNumResultsToDisplay(int numResultsToDisplay) {
		this.numResultsToDisplay = numResultsToDisplay;
	}
	
	public String getCollectionIdField() {
		return collectionIdField;
	}

	public void setCollectionIdField(String collectionIdField) {
		this.collectionIdField = collectionIdField;
	}

	public String[] getFilterQueries() {
		return filterQueries;
	}

	public void setFilterQueries(String[] filterQueries) {
		this.filterQueries = filterQueries;
	}
	
	public String getDatestampField() {
		return datestampField;
	}

	public void setDatestampField(String datestampField) {
		this.datestampField = datestampField;
	}
	
	public String getSetIdField() {
		return setIdField;
	}

	public void setSetIdField(String setIdField) {
		this.setIdField = setIdField;
	}

	public String getSetNameField() {
		return setNameField;
	}

	public void setSetNameField(String setNameField) {
		this.setNameField = setNameField;
	}

	public String getSetDescField() {
		return setDescField;
	}

	public void setSetDescField(String setDescField) {
		this.setDescField = setDescField;
	}

	public String[] getSetQueries() {
		return setQueries;
	}

	public void setSetQueries(String[] setQueries) {
		this.setQueries = setQueries;
	}
	
	public String getSetPrefix()
	{
		return setPrefix;
	}
	
	public void setSetPrefix(String setPrefix)
	{
		this.setPrefix = setPrefix;
	}

	@Override
	public void setApplicationContext(ApplicationContext arg0) throws BeansException {
		appContext = arg0;		
	}
}
