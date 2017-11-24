package br.com.dependencias;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import org.apache.log4j.Logger;
import org.repodriller.domain.Commit;
import org.repodriller.domain.Modification;
import org.repodriller.domain.ModificationType;
import org.repodriller.persistence.PersistenceMechanism;
import org.repodriller.scm.CommitVisitor;
import org.repodriller.scm.SCMRepository;

/**
 *
 * @author mairieliw
 */
public class ModificationsVisitor implements CommitVisitor {

    private static final Logger logger = Logger.getLogger(ModificationsVisitor.class);
    private List<VisitedCommit> visitedCommits;
    private Map<String, String> renamedFiles;

    public ModificationsVisitor() {
	this.visitedCommits = new LinkedList<>();
	this.renamedFiles = new Hashtable<>();
    }

    @Override
    public void process(SCMRepository repo, Commit commit, PersistenceMechanism writer) {

	List<String> files = new ArrayList<>();

	for (Modification m : commit.getModifications()) {
	    if (m.wasDeleted()) {
		continue;
	    } else if (m.getType() == ModificationType.RENAME) {
		this.renamedFiles.put(m.getOldPath(), m.getNewPath());
		renameFile(m.getOldPath(), m.getNewPath());
		continue;
	    }

	    if (m.fileNameEndsWith("gif") || m.fileNameEndsWith("jpeg")
		    || m.fileNameEndsWith("jpg") || m.fileNameEndsWith("png")) {
		continue;
	    }

	    files.add(m.getNewPath());
	}

	if (!files.isEmpty() && commit.getModifications().size() <= 30) {
	    VisitedCommit com = new VisitedCommit();
	    com.setAuthor(commit.getAuthor().getName());
	    com.setCommitDate(commit.getDate().getTime());
	    com.setHash(commit.getHash());
	    com.setRepo(repo.getLastDir());
	    com.setFiles(files);
	    synchronized (visitedCommits) {
		visitedCommits.add(com);
	    }
	} else {
	    logger.info("skipped commit " + commit.getHash());
	}
    }

    public List<VisitedCommit> getCommits() {
	return visitedCommits;
    }

    public Map<String, String> getRenamedFiles() {
	return renamedFiles;
    }

    private void renameFile(String oldName, String newName) {
	 synchronized (visitedCommits) {
	     for (VisitedCommit v : visitedCommits){
		 if(v.getFiles().contains(oldName)){
		     v.getFiles().remove(oldName);
		     v.getFiles().add(newName);
		 }
	     }
	 }
    }

    @Override
    public String name() {
	return "modifications-per-commit";
    }
}
