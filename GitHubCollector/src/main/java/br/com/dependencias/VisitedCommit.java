package br.com.dependencias;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

/**
 *
 * @author mairieliw
 */
public class VisitedCommit {

    private String repo;
    private String author;
    private String hash;
    private Date commitDate;
    private List<String> files;

    public VisitedCommit() {
	this.files = new LinkedList<>();
    }
    
    public String getRepo() {
	return repo;
    }

    public void setRepo(String repo) {
	this.repo = repo;
    }

    public String getAuthor() {
	return author;
    }

    public void setAuthor(String author) {
	this.author = author;
    }

    public String getHash() {
	return hash;
    }

    public void setHash(String hash) {
	this.hash = hash;
    }

    public Date getCommitDate() {
	return commitDate;
    }

    public void setCommitDate(Date commitDate) {
	this.commitDate = commitDate;
    }

    public List<String> getFiles() {
	return files;
    }

    public void setFiles(List<String> files) {
	this.files = files;
    }

    @Override
    public String toString() {
	return repo + ";"
		+ author + ";"
		+ hash + ";"
		+ new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(commitDate) + ";"
		+ String.join(",", files);
    }

}
