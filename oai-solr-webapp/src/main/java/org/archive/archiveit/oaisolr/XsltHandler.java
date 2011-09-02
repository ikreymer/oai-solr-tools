package org.archive.archiveit.oaisolr;

import java.io.IOException;

import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.springframework.beans.factory.annotation.Configurable;

@Configurable
public class XsltHandler  implements URIResolver {
	
	private TransformerFactory transformerFactory;
	private String xsltDirPath = "";
	private String xsltFullPath;
	private String xsltErrorPath = "error.xsl";

	public XsltHandler()
	{
		transformerFactory = TransformerFactory.newInstance();
		transformerFactory.setURIResolver(this);
	}
	
	public void setXsltPath(String fullPath)
	{
		int index = fullPath.lastIndexOf('/');
		if (index >= 0) {
			xsltDirPath = fullPath.substring(0, index + 1);
		} else {
			xsltDirPath = "";
		}
		xsltFullPath = fullPath;
	}
	
	public ClientXsltSolrResponseParser newParserInstance(HttpServletResponse response) throws TransformerConfigurationException
	{		
		StreamSource source = new StreamSource(getClass().getClassLoader().getResourceAsStream(xsltFullPath));
		Transformer transformer = transformerFactory.newTransformer(source);
		return new ClientXsltSolrResponseParser(response, transformer);
	}
	
	public void sendErrorXml(HttpServletResponse response, String errorMsg, String requestStr) throws IOException
	{
		StreamSource source = new StreamSource(getClass().getClassLoader().getResourceAsStream(xsltDirPath + xsltErrorPath));
		
		try {
			Transformer transformer = transformerFactory.newTransformer(source);
			transformer.setParameter("errorMsg", errorMsg);
			transformer.setParameter("requestStr", requestStr);
			transformer.transform(new DOMSource(), new StreamResult(response.getWriter()));
		} catch (Exception e) {
			e.printStackTrace();
			response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
		}
	}
	
	public Source resolve(String href, String base) throws TransformerException {
			
		//System.out.println("href: " + href);
		
		return new StreamSource(getClass().getClassLoader().getResourceAsStream(xsltDirPath + href));
	}
}
