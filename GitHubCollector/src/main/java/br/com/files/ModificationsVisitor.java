package br.com.files;

import br.com.dependencias.*;
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
    private Integer files = 0;
    private List<String> pastFiles;

    public ModificationsVisitor() {
	pastFiles = new LinkedList<>();
    }

    @Override
    public void process(SCMRepository repo, Commit commit, PersistenceMechanism writer) {

	for (Modification m : commit.getModifications()) {
	    if (m.wasDeleted()) {
		synchronized (files) {
		    files--;
		}
	    } else {
		synchronized (files) {
		    if (!pastFiles.contains(m.getOldPath())) {
			pastFiles.add(m.getOldPath());
			files++;
		    }
		}
	    }

	}
    }

    public Integer getFiles() {
	return files;
    }

    @Override
    public String name() {
	return "modifications-per-commit";
    }
}
